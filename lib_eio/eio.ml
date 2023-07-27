include Eio__core

module Ctf = struct
  let with_tracing fn =
    Ctf.Control.start ();
    Fun.protect fn ~finally:(fun () -> Ctf.Control.stop ())
end

module Fibre = Fiber

module Debug = Private.Debug
let traceln = Debug.traceln

module Std = struct
  module Promise = Promise
  module Fiber = Fiber
  module Switch = Switch
  let traceln = Debug.traceln
end

module Semaphore = Semaphore
module Mutex = Eio_mutex
module Condition = Condition
module Stream = Stream
module Exn = Exn
module Generic = Generic
module Flow = Flow
module Buf_read = Buf_read
module Buf_write = Buf_write
module Net = Net
module Process = Process
module Domain_manager = Domain_manager
module Time = Time
module File = File
module Fs = Fs
module Path = Path

module Stdenv = struct
  let stdin  (t : <stdin  : #Flow.source; ..>) = t#stdin
  let stdout (t : <stdout : #Flow.sink;   ..>) = t#stdout
  let stderr (t : <stderr : #Flow.sink;   ..>) = t#stderr
  let net (t : <net : #Net.t; ..>) = t#net
  let process_mgr (t : <process_mgr : #Process.mgr; ..>) = t#process_mgr
  let domain_mgr (t : <domain_mgr : #Domain_manager.t; ..>) = t#domain_mgr
  let clock (t : <clock : #Time.clock; ..>) = t#clock
  let mono_clock (t : <mono_clock : #Time.Mono.t; ..>) = t#mono_clock
  let secure_random (t: <secure_random : #Flow.source; ..>) = t#secure_random
  let fs (t : <fs : #Fs.dir Path.t; ..>) = t#fs
  let cwd (t : <cwd : #Fs.dir Path.t; ..>) = t#cwd
  let debug (t : <debug : 'a; ..>) = t#debug
  let backend_id (t: <backend_id : string; ..>) = t#backend_id
end

exception Io = Exn.Io
