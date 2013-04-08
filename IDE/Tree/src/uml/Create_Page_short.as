@startuml img/sequence_img001.png

participant MenuPanel << (M,#ADD1B2) >>
participant OpenCreatePageWindowRequest << (C,#ADD1B2) >>
participant TreeJunction << (M,#ADD1B2) >>
participant PageCreated << (C,#ADD1B2) >>
participant Structure << (P,#ADD1B2) >>
participant WorkArea << (M,#ADD1B2) >>			
participant SelectedTreeElementChangeRequest << (C,#ADD1B2) >>
	
	
title: Create Page\n\n( C ) - Command\n( M ) - Mediator\n( P ) - Proxy\n

MenuPanel -> MenuPanel:	CREATE_PAGE
MenuPanel -> OpenCreatePageWindowRequest: OPEN_CREATE_PAGE_\nWINDOW_REQUEST
note over of OpenCreatePageWindowRequest: new CreatePageWindow()\nregisterMediator CreatePageWindowMediator

OpenCreatePageWindowRequest -> TreeJunction: OPEN_WINDOW 
note over of TreeJunction: open window for chose\ntop lavel conteiner of new Page

TreeJunction -> PageCreated: PAGE_CREATED
note over of PageCreated: create TreeElement\n in structureProxy

PageCreated -> Structure

Structure -> WorkArea:	TREE_ELEMENTS_\nCHANGED\n(treeElements)
note  over of WorkArea: add treeElement;\nsetSelectTreeElement();

Structure -> SelectedTreeElementChangeRequest: SELECTED_TREE_ELEMENT_CHANGE_REQUEST
note  over of SelectedTreeElementChangeRequest: set sessionProxy.selectedTreeElement

SelectedTreeElementChangeRequest -> TreeJunction: SET_SELECTED_PAGE\n(pageVO)

@enduml	