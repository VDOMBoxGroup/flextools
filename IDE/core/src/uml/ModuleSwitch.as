// ActionScript file
@startuml img/sequence_img001.png
title Переключение между модулями Mod2 -> Mod1
	Mod1 -> Core : Message:\nI wanna be selected
	Core -> Mod2 : Run function:\nMod2.deSelect()
	Core -> Mod1 : Run function:\nMod1.getBody()	
	
@enduml	
	
	
participant  ToolsetMediator <<(W, #ADDdB2) >>
participant  BodyMediator <<(W, #ADDdB2) >>
participant  WysiwygJunctionMediator <<(W, #ADDdB2) >>		
participant  ProcessSimpleMessageCommand <<(С, #ADDdB2) >>	
participant  MainWindowMediator <<(С, #ADDdB2) >>	
participant  CoreJunctionMediator <<(С, #ADDdB2) >>	
participant  ProxiesJunctionMediator <<(С, #ADDdB2) >>
participant  StatesProxyRequestCommand <<(С, #ADDdB2) >>
	
	
		
	
title Переключение между модулями Tree -> Wisiwig
	
	
ToolsetMediator -> WysiwygJunctionMediator : SELECT_MODULE

note over of WysiwygJunctionMediator:  	created a message
WysiwygJunctionMediator -> ProcessSimpleMessageCommand : PROCESS_SIMPLE_MESSAGE

ProcessSimpleMessageCommand -> MainWindowMediator :CHANGE_SELECTED_MODULE

note over of MainWindowMediator:  	Remove All Elements\n&run module.getBody();

MainWindowMediator -> CoreJunctionMediator : SELECTED_MODULE_CHANGED
CoreJunctionMediator -> WysiwygJunctionMediator : MODULE_SELECTED


CoreJunctionMediator -> ProcessSimpleMessageCommand : PROCESS_SIMPLE_MESSAGE


ProcessSimpleMessageCommand -> ProxiesJunctionMediator :CONNECT_MODULE_TO_PROXIES
ProxiesJunctionMediator -> CoreJunctionMediator : MODULE_TO_PROXIES_CONNECTED
CoreJunctionMediator -> WysiwygJunctionMediator : MODULE_TO_PROXIES_CONNECTED	
WysiwygJunctionMediator -> BodyMediator : PROXIES_PIPE_CONNECTED	
WysiwygJunctionMediator -> WysiwygJunctionMediator : GET_ALL_STATES	 	
WysiwygJunctionMediator -> ProxiesJunctionMediator : PROXIESOUT
ProxiesJunctionMediator -> StatesProxyRequestCommand : STATES_PROXY_REQUEST
StatesProxyRequestCommand -> ProxiesJunctionMediator : STATES_PROXY_RESPONSE
ProxiesJunctionMediator -> WysiwygJunctionMediator : PROXIESOUT
	
	

@enduml	

	
	