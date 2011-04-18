@startuml img/sequence_img001.png


participant	ResourceSelector.mxml	
participant ObjectAttributesPanel << (M,#ADD1B2) >>
participant	OpenResourceSelectorRequest << (C,#ADD1B2) >>	
participant ResourceSelectorWindow << (M,#ADD1B2) >>
participant ResourceSelectorWindow.mxml	
participant	WysiwygJunction << (M,#ADD1B2) >>
	
box "Core" #LightBlue
	participant SOAP 
	participant Resources << (P,#ADD1B2) >>	
	participant	ResourcesProxyResponse << (C,#ADD1B2) >>
	participant	ProxiesJunction << (M,#ADD1B2) >>
end box

participant ProcessResourcesProxyMessage << (C,#ADD1B2) >>


title:Chose Resource\n\n( M ) - Mediator\n( C ) - Command\n( P ) - Proxy\n 


ResourceSelector.mxml -> ObjectAttributesPanel: AttributeEvent.SELECT_RESOURCE	
ObjectAttributesPanel -> OpenResourceSelectorRequest: OPEN_RESOURCE_\nSELECTOR_REQUEST\n(event.target)
note over of OpenResourceSelectorRequest: open ResourceSelectorWindow\n with resourceSelector

OpenResourceSelectorRequest -> ResourceSelectorWindow: register
ResourceSelectorWindow -> WysiwygJunction: GET_RESOURCES(sessionProxy.selectedApplication)


WysiwygJunction -> SOAP
SOAP -> Resources: soap_resultHandler\n("list_resources")
Resources -> ResourcesProxyResponse: RESOURCES_GETTED\n(resources)
ResourcesProxyResponse -> ProxiesJunction: RESOURCES_PROXY_\nRESPONSE
ProxiesJunction -> WysiwygJunction: junction.sendMessage(...)

WysiwygJunction -> ProcessResourcesProxyMessage: PROCESS_RESOURCES_\nPROXY_MESSAGE
ProcessResourcesProxyMessage -> ResourceSelectorWindow: RESOURCES_GETTED
ResourceSelectorWindow -> ResourceSelectorWindow.mxml: set resources


@enduml	