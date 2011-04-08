@startuml img/sequence_img001.png

participant TreeElement.mxml 
participant SelectedTreeElementChangeRequest << (C,#ADD1B2) >>
participant CoreJunction << (M,#ADD1B2) >>
participant ProcessStatesProxyMessage << (C,#ADD1B2) >>
participant PropertiesPanel << (M,#ADD1B2) >>
	
title Select Page\n(C) - Command\n(M) - Mediator
	
	
TreeElement.mxml -> SelectedTreeElementChangeRequest
note left: Select

SelectedTreeElementChangeRequest -> CoreJunction
note left: set sessionProxy.selectedTreeElement

CoreJunction -> ProcessStatesProxyMessage
note left: set selected Page

ProcessStatesProxyMessage -> ProcessStatesProxyMessage
note left: set sessionProxy.selectedPage

ProcessStatesProxyMessage -> PropertiesPanel

PropertiesPanel -> PropertiesPanel
note left: clear fields

PropertiesPanel -> CoreJunction: GET_PAGE_ATTRIBUTES
CoreJunction --> PropertiesPanel:vdomObjectAttributesVO

PropertiesPanel -> PropertiesPanel
note left: set the necessary values

PropertiesPanel -> PropertiesPanel
note left: propertiesPanel.treeElementVO =\n sessionProxy.selectedTreeElement;

@enduml	
