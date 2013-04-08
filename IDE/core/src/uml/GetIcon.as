@startuml img/sequence_img001.png

participant SameMediator
participant	WysiwygJunction << (M,#ADD1B2) >>
	
box "Core" #LightBlue
	participant	ProxiesJunction << (M,#ADD1B2) >>
	participant	ResourcesProxyRequest << (C,#ADD1B2) >>
	participant Resources << (P,#ADD1B2) >>	
	participant	ResourcesProxyResponse << (C,#ADD1B2) >>
	
end box

participant ProcessResourcesProxyMessage << (C,#ADD1B2) >>

title:Get Icon of Resource\n\n( M ) - Mediator\n( C ) - Command\n( P ) - Proxy\n 

SameMediator -> WysiwygJunction: GET_ICON\n{ resourceVO: resourceVO,\nrecipientKey: mediatorName}
WysiwygJunction -> ProxiesJunction: junction.sendMessage(...)
ProxiesJunction	-> ResourcesProxyRequest: RESOURCES_PROXY_REQUEST\n(ppMessage)
ResourcesProxyRequest -> Resources: getIcon( resourceVO ); 

alt  type is not visible
Resources -> Resources: creationIconCompleted\n( resourceVO, file )

else
alt  file is located in the file system user
Resources -> Resources: creationIconCompleted\n( resourceVO, file from FS )

else
Resources -> Resources : createIcon()

end alt
end alt


Resources -> ResourcesProxyResponse: ICON_GETTED\n(resourceVO)
ResourcesProxyResponse -> ProxiesJunction: RESOURCES_PROXY_\nRESPONSE
ProxiesJunction -> WysiwygJunction: junction.sendMessage(...)
WysiwygJunction -> ProcessResourcesProxyMessage:	PROCESS_RESOURCES_PROXY_MESSAGE(message)
ProcessResourcesProxyMessage -> SameMediator: ICON_GETTED(body)
	
@enduml	