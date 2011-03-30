// ActionScript file
@startuml img/sequence_img001.png

	
participant  ToolsetMediator <<(W, #ADDdB2) >>
participant  BodyMediator <<(W, #ADDdB2) >>
participant  WysiwygJunctionMediator <<(W, #ADDdB2) >>		
participant  ProcessSimpleMessageCommand <<(С, #ADDdB2) >>	
participant  MainWindowMediator <<(С, #ADDdB2) >>	
participant  CoreJunctionMediator <<(С, #ADDdB2) >>	
participant  ProxiesJunctionMediator <<(С, #ADDdB2) >>
participant  StatesProxyRequestCommand <<(С, #ADDdB2) >>
participant  TreeJunctionMediator <<(T, #ADDdB2) >>
	
participant  ProcessStatesProxyMessageCommand <<(T, #ADDdB2) >>
participant  TreeBodyMediator <<(T, #ADDdB2) >>	
	
		
	
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
ProxiesJunctionMediator -> TreeJunctionMediator : PROXIESOUT
	
TreeJunctionMediator -> ProcessStatesProxyMessageCommand :   ALL_STATES
	
ProcessStatesProxyMessageCommand -> TreeBodyMediator :   ALL_STATES_GETTED
note over of TreeBodyMediator:  	Пошло в не правильное русло\nначало запрашивать странички\nприложения

 






@enduml	
title Взаимодействие между Модулем (M) и Движком (C)
box "in side Module"
participant  WorkAreaMediator  
participant  SaveRequestCommand 
participant  TreeJunctionMediator  
end box

participant  Core <<(С, #ADDdB2) >>			
	
	
	WorkAreaMediator -> SaveRequestCommand  : sendNotification(..) 
note over of SaveRequestCommand:  ApplicationFacade.\nSAVE_REQUEST

SaveRequestCommand -> TreeJunctionMediator :  sendNotification(..) 
note over of TreeJunctionMediator:  	 ApplicationFacade.\nSET_APPLICATION_STRUCTURE


TreeJunctionMediator -> Core : 	junction.sendMessage(..)
	note over of Core:  	 PipeNames.PROXIESOUT,\n message

Core --/  a : 	junction.sendMessage(..)
	
	