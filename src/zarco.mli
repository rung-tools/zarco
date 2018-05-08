
module Version : sig
  type t
end

module I18n_string : sig
  type t = (string * string) list
end

module Package : sig
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

  val of_zip : string -> unit
  val to_zip : t -> unit
  val of_dir : string -> unit

  (* val of_zip : string -> t Js.Promise.t
  val to_zip : t -> string Js.Promise.t
  val of_dir : string -> t Js.Promise.t *)
end
