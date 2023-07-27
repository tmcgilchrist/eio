[@@@alert "-unstable"]

module Fd = Fd
module Resource = Resource
module Private = Private

include Types
type socket = Net.stream_socket

let await_readable = Private.await_readable
let await_writable = Private.await_writable
let pipe = Private.pipe

type Eio.Exn.Backend.t += Unix_error of Unix.error * string * string
let () =
  Eio.Exn.Backend.register_pp (fun f -> function
      | Unix_error (code, name, arg) -> Fmt.pf f "Unix_error (%s, %S, %S)" (Unix.error_message code) name arg; true
      | _ -> false
    )

let sleep d =
  Eio.Time.Mono.sleep (Effect.perform Private.Get_monotonic_clock) d

let run_in_systhread = Private.run_in_systhread

module Ipaddr = Net.Ipaddr

module Process = Process
module Net = Net

module Stdenv = struct
  type base = <
    stdin  : source;
    stdout : sink;
    stderr : sink;
    net : Eio.Net.t;
    domain_mgr : Eio.Domain_manager.t;
    process_mgr : Process.mgr;
    clock : Eio.Time.clock;
    mono_clock : Eio.Time.Mono.t;
    fs : Eio.Fs.dir Eio.Path.t;
    cwd : Eio.Fs.dir Eio.Path.t;
    secure_random : Eio.Flow.source;
    debug : Eio.Debug.t;
    backend_id: string;
  >
end

let getnameinfo (sockaddr : Eio.Net.Sockaddr.t) =
  let sockaddr, options =
    match sockaddr with
    | `Unix s -> (Unix.ADDR_UNIX s, [])
    | `Tcp (addr, port) -> (Unix.ADDR_INET (Ipaddr.to_unix addr, port), [])
    | `Udp (addr, port) -> (Unix.ADDR_INET (Ipaddr.to_unix addr, port), [Unix.NI_DGRAM])
  in
  run_in_systhread (fun () ->
    let Unix.{ni_hostname; ni_service} = Unix.getnameinfo sockaddr options in
    (ni_hostname, ni_service))
