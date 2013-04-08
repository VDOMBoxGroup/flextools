@startuml img/sequence_img001.png

participant SameMediator
participant	WysiwygJunction << (M,#ADD1B2) >>
	
box "Core" #LightBlue
	participant	ProxiesJunction << (M,#ADD1B2) >>
	participant	ResourcesProxyRequest << (C,#ADD1B2) >>
	participant Resources << (P,#ADD1B2) >>	
	participant	ResourcesProxyResponse << (C,#ADD1B2) >>
	participant	sameBody
	participant	Soap
	
end box


title:Choice of Resource\n\n( M ) - Mediator\n( C ) - Command\n( P ) - Proxy\n 

note over SameMediator: loadResource and create resourceVO:\nresourceVO = new ResourceVO( app.id );\nresourceVO.setID( openFile.name );\nresourceVO.data = openFile.data;\nresourceVO.name = openFile.name;\nresourceVO.type = openFile.type;
SameMediator -> WysiwygJunction: SET_RESOURCE\n( resourceVO )
WysiwygJunction -> ProxiesJunction: junction.sendMessage(...)
ProxiesJunction	-> ResourcesProxyRequest: RESOURCES_PROXY_REQUEST\n(ppMessage)
ResourcesProxyRequest -> Resources: loadResource\n( resourceVO ); 
Resources -> Resources: soap_setResource
note over Resources: Compress and Encode to Base64\nresourceVO.setStatus( ResourceVO.UPLOAD_PROGRESS );

sameBody -> Soap: operationResultHandler\n({resultXML,...})
Soap -> Resources: soap_resultHandler()
note over Resources: set id to resourceVO\n resourceVO.setStatus( ResourceVO.UPLOADED );
Resources -> ResourcesProxyResponse: RESOURCE_SETTED\n(resourceVO)
ResourcesProxyResponse -> ProxiesJunction: RESOURCES_PROXY_RESPONSE(message)	
	


@enduml	