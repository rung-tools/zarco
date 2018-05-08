
module Version = struct
  type t = string

  external of_string : string -> t option = "valid"
  [@@bs.module "semver"][@@bs.return nullable]

  let to_string t = t
end

module StringMap = Map.Make (String)

module I18n_string = struct
  type t = (string * string) list
end

module Package_json = struct
  type t = {
    name: string;
    version: Version.t;
    author: string option;
    category: string option;
    license: string option
  }

  let get_string_exn obj key =
    match Js.Dict.get obj key with
    | Some x ->
      begin match Js.Json.classify x with
      | Js.Json.JSONString name -> name
      | _ -> failwith ("/package.json: expected key '" ^ key ^ "' to be a string")
      end
    | None -> failwith ("/package.json: required key '" ^ key ^ "' not found")

  let get_string obj key =
    try Some (get_string_exn obj key) with
    | _ -> None

  let of_string_exn s =
    let open Js.Json in
    let json =
      try parseExn s with
      | _ -> failwith "/package.json: parse failed"
    in
    match classify json with
    | JSONObject package ->
      { name = get_string_exn package "name";
        version = get_string_exn package "version";
        author = get_string package "author";
        category = get_string package "category";
        license = get_string package "license" }
    | _ -> failwith "/package.json: expected root to be an object"
end

module Package = struct

  open Js.Promise

  type t = {
    name     : string;
    version  : Version.t;
    keywords : string list;
    homepage : string option;
    author   : string option;
    title    : I18n_string.t;
    picture  : string;
    source   : string;
  }

  let then_resolve f p = then_ (fun a -> resolve @@ f a) p

  let get_file_exn name map =
    try StringMap.find name map with
    | Not_found -> failwith ("zip: required file '" ^ name ^ "' not_found")

  let t_of_map map =
    let package_json =
      map
      |> get_file_exn "package.json"
      |> Package_json.of_string_exn
    in
    let locales =
      StringMap.bindings map
      |> List.map (fun (key, _) -> key)
      |> List.filter (fun s ->
        Js.Re.test s [%bs.re "/^locales(\/|\\\)[a-z]{2,3}(_[A-Z]{2})?\.json$/"])
      |> List.map (fun name ->
        (Node.Path.basename_ext name ".json",
         Js.Json.parseExn @@ get_file_exn name map))
    in
    let source = get_file_exn "index.js" map in
    Js.log package_json;
    Js.log locales;
    Js.log source

  let map_of_zip zip =
    let files = Zip.filter (fun _ obj -> not obj##dir) zip in
    files
    |> Js.Array.map
      (fun file -> all2 @@ (resolve file##name, Zip.Obj.get_contents file))
    |> all
    |> then_resolve
      (Js.Array.reduce
        (fun map (name, contents) -> StringMap.add name contents map)
        StringMap.empty)

  let of_zip zip_string =
    let open Zip in
    Zip.load zip_string
    |> then_ map_of_zip
    |> then_resolve t_of_map
    |> ignore

  let to_zip string = ()
  let of_dir path = ()
end
