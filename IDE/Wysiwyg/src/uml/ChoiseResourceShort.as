@startuml img/sequence_img001.png


participant	ResourceSelector.mxml	
participant ObjectAttributesPanel << (M,#ADD1B2) >>
participant	OpenResourceSelectorRequest << (C,#ADD1B2) >>	
participant ResourceSelectorWindow << (M,#ADD1B2) >>
participant ResourceSelectorWindow.mxml	
participant	WysiwygJunction << (M,#ADD1B2) >>
	
box "Core" #LightBlue
	participant SOAP 	
end box

participant ProcessResourcesProxyMessage << (C,#ADD1B2) >>


title:Choise of Resource (Short)\n\n( M ) - Mediator\n( C ) - Command\n( P ) - Proxy\n 


ResourceSelector.mxml -> ObjectAttributesPanel: SELECT_RESOURCE	
ObjectAttributesPanel -> OpenResourceSelectorRequest: OPEN_RESOURCE_\nSELECTOR_REQUEST\n(event.target)
note over of OpenResourceSelectorRequest: open ResourceSelectorWindow\n with resourceSelector

OpenResourceSelectorRequest -> ResourceSelectorWindow: register
ResourceSelectorWindow -> WysiwygJunction: GET_RESOURCES(sessionProxy.selectedApplication)


WysiwygJunction -> SOAP
note over of SOAP: get resources
SOAP -> WysiwygJunction

WysiwygJunction -> ProcessResourcesProxyMessage: PROCESS_RESOURCES_\nPROXY_MESSAGE
ProcessResourcesProxyMessage -> ResourceSelectorWindow: RESOURCES_GETTED
ResourceSelectorWindow -> ResourceSelectorWindow.mxml: set resources


@enduml	