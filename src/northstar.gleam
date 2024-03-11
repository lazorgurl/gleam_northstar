import gleam/erlang/process
import gleam/bytes_builder
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import mist.{type Connection, type ResponseData}
import glint
import glint/flag
import argv

fn port_flag() -> flag.FlagBuilder(Int) {
  flag.int()
  |> flag.default(8080)
  |> flag.description("set the port for the server")
}

fn root_cmd(input: glint.CommandInput) -> Nil {
  let assert Ok(port) = flag.get_int(from: input.flags, for: "port")

  let assert Ok(_) =
    router
    |> mist.new
    |> mist.port(port)
    |> mist.start_http

  process.sleep_forever()
}

pub fn main() {
  glint.new()
  |> glint.with_name("northstar")
  |> glint.with_pretty_help(glint.default_pretty_help())
  |> glint.add(
    at: [],
    do: glint.command(root_cmd)
      |> glint.flag("port", port_flag())
      |> glint.description("run the server"),
  )
  |> glint.run(argv.load().arguments)
}

fn router(_req: Request(Connection)) -> Response(ResponseData) {
  response.new(200)
  |> response.set_body(mist.Bytes(bytes_builder.from_string("OK")))
  |> response.set_header("Content-Type", "text/plain")
}
