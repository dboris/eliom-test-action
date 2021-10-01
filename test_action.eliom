let main_service =
  Eliom_service.create
    ~path:(Eliom_service.Path [])
    ~meth:(Eliom_service.Get Eliom_parameter.unit)
    ()

let connect_service =
  Eliom_service.create_attached_get
    ~name:"connect"
    ~fallback:main_service
    ~get_params:(Eliom_parameter.string "name")
    ()

let () =
  let username : string option Eliom_reference.eref =
    Eliom_reference.eref ~scope:Eliom_common.default_session_scope None
  in
  Eliom_registration.Html.register
    ~service:main_service
    (fun () () ->
      let%lwt name_opt = Eliom_reference.get username in
      let name = Option.value name_opt ~default:"from Eliom's distillery!" in
      Lwt.return
        (Eliom_tools.F.html
          ~title:"test_action"
          ~css:[["css";"test_action.css"]]
          Eliom_content.Html.F.(body [
            h1 [txt @@ "Welcome " ^ name];
            a ~service:connect_service [txt "Connect"] "John"
          ])));
  Eliom_registration.Action.register
    ~service:connect_service
    (fun name () -> Eliom_reference.set username (Some name))
