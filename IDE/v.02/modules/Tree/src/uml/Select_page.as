@startuml img/sequence_img001.png

participant TreeElement.mxml 
participant TreeElement << (M,#ADD1B2) >>
participant SelectedTreeElementChangeRequest << (C,#ADD1B2) >>
participant TreeJunction << (M,#ADD1B2) >>
participant CoreJunction << (M,#ADD1B2) >>
participant ProcessStatesProxyMessage << (C,#ADD1B2) >>
participant Session << (P,#ADD1B2) >>
participant PropertiesPanel << (M,#ADD1B2) >>
participant	PropertiesPanel.mxml
participant ProcessPageProxyMessage << (C,#ADD1B2) >>


	
title Select Page

TreeElement.mxml -> TreeElement:	SELECTION

note left: (C) - Command\n(M) - Mediator\n(P) - Proxy

TreeElement -> TreeElement:  elementSelectionHandler
TreeElement -> SelectedTreeElementChangeRequest: AppF.SELECTED_TREE_ELEMENT_CHANGE_REQUEST\n(treeElementVO)
SelectedTreeElementChangeRequest -> TreeJunction: AppF.SET_SELECTED_PAGE\n(pageVO)
TreeJunction -> CoreJunction:	(STATES,UPDATE,SELECTED_PAGE,pageVO)
CoreJunction --> TreeJunction: result
TreeJunction -> ProcessStatesProxyMessage: AppF.PROCESS_APPLICATION_PROXY_MESSAGE\n(message)
note right: sessionProxy.selectedPage = selectedPageVO;
ProcessStatesProxyMessage -> Session:set selectedPage\n(pageVO)
Session -> PropertiesPanel: AppF.SELECTED_PAGE_CHANGED
PropertiesPanel -> PropertiesPanel.mxml: set vdomObjectAttributesVO(null)
note right: clear fields
PropertiesPanel.mxml -> PropertiesPanel.mxml: pageAttributesChanged()


PropertiesPanel -> TreeJunction: AppF.GET_PAGE_ATTRIBUTES\n(selectedPage, mediatorName)
TreeJunction -> ProcessPageProxyMessage: AppF.PROCESS_STATES_PROXY_MESSAGE\n(message)
ProcessPageProxyMessage -> PropertiesPanel:AppF.PAGE_ATTRIBUTES_GETTED + \nNotifications.DELIMITER + \nrecipientID, \nvdomObjectAttributesVO;
PropertiesPanel -> PropertiesPanel.mxml: set vdomObjectAttributesVO(value)
note right: set the necessary values
PropertiesPanel.mxml -> PropertiesPanel.mxml: pageAttributesChanged()
PropertiesPanel -> PropertiesPanel
note right: propertiesPanel.treeElementVO =\n sessionProxy.selectedTreeElement;

@enduml	
