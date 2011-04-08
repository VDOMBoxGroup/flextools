@startuml img/sequence_img001.png

participant MenuPanel.mxml
participant MenuPanel << (M,#ADD1B2) >>
participant OpenCreatePageWindowRequest << (C,#ADD1B2) >>
participant TreeJunction << (M,#ADD1B2) >>
participant CoreJunction << (M,#ADD1B2) >>
participant ProcessSimpleMessage << (C,#ADD1B2) >>
participant OpenWindow << (C,#ADD1B2) >>	
participant CreatePageWindow << (M,#ADD1B2) >>	
	
participant CloseWindow << (CC,#ADD1B2) >>	
participant CreatePageRequest << (CT,#ADD1B2) >>	
	
participant ApplicationProxy << (C,#ADD1B2) >>	
participant ApplicationProxyResponse << (CC,#ADD1B2) >>		
participant ProxiesJunction << (CM,#ADD1B2) >>
participant ProcessApplicationProxyMessage << (C,#ADD1B2) >>
participant PageCreated << (C,#ADD1B2) >>
participant Structure << (P,#ADD1B2) >>
participant WorkArea << (M,#ADD1B2) >>			
participant SelectedTreeElementChangeRequest << (C,#ADD1B2) >>		
				
				
MenuPanel.mxml -> MenuPanel:	CREATE_PAGE
MenuPanel -> MenuPanel:  menuPanel_createPageHandler
MenuPanel -> OpenCreatePageWindowRequest: AppF.OPEN_CREATE_PAGE_WINDOW_REQUEST
OpenCreatePageWindowRequest -> TreeJunction:	AppF.OPEN_WINDOW(content: createPageWindow, title: "Create Page", ...) 
TreeJunction -> CoreJunction:	handlePipeMessage(STATES.UPDATE.SELECTED_PAGE)
CoreJunction -> ProcessSimpleMessage:	AppF.PROCESS_SIMPLE_MESSAGE(message)
ProcessSimpleMessage -> OpenWindow:	OPEN_WINDOW(body)


CreatePageWindow -> TreeJunction:	CLOSE_WINDOW(createPageWindow)
TreeJunction ->	 ProcessSimpleMessage: SimpleMessageHeaders.CLOSE_WINDOW
ProcessSimpleMessage -> CloseWindow:	AppF.CLOSE_WINDOW	
	
	
CreatePageWindow -> CreatePageRequest: AppF.CREATE_PAGE_REQUEST(selectedPageType)	
CreatePageRequest -> TreeJunction:	CREATE_PAGE(AppF.CREATE_PAGE,	{ applicationVO, typeVO })
ApplicationProxy -> ApplicationProxyResponse:	AppF.APPLICATION_PAGE_CREATED(applicationVO, pageVO)
ApplicationProxyResponse -> ProxiesJunction:	AppF.APPLICATION_PROXY_RESPONSE(message)
ProxiesJunction -> TreeJunction	
TreeJunction -> ProcessApplicationProxyMessage
ProcessApplicationProxyMessage -> PageCreated:	AppF.PAGE_CREATED(body)
PageCreated -> Structure:	createTreeElementByVO(pageVO)	
Structure -> WorkArea:	AppF.TREE_ELEMENTS_CHANGED(treeElements)
Structure -> SelectedTreeElementChangeRequest: SELECTED_TREE_ELEMENT_CHANGE_REQUEST
SelectedTreeElementChangeRequest -> TreeJunction: SET_SELECTED_PAGE(pageVO)

@enduml	