
open Zarco

let () =
    Node.Fs.readFileSync "find-property.rung" `binary
    |> Zarco.Package.of_zip
