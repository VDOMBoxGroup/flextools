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

SameMediator -> WysiwygJunction: LOAD_RESOURCE\n{ resourceVO: resourceVO,\nrecipientKey: mediatorName}
WysiwygJunction -> ProxiesJunction: junction.sendMessage(...)
ProxiesJunction	-> ResourcesProxyRequest: RESOURCES_PROXY_REQUEST\n(ppMessage)
ResourcesProxyRequest -> Resources: loadResource( resourceVO ); 
alt  file is located in the file system user
note over Resources: resourceVO.setData( resource );\n resourceVO.setStatus( ResourceVO.LOADED );

Resources -> ResourcesProxyResponse: RESOURCE_LOADED(resourceVO)
ResourcesProxyResponse -> ProxiesJunction: RESOURCES_PROXY_RESPONSE(message)

else 
note over Resources:resourceVO.setStatus( ResourceVO.LOAD_PROGRESS );
ResourcesProxyResponse -> ProxiesJunction: RESOURCES_PROXY_RESPONSE(message)

== loading resources from server ==

sameBody -> Soap: operationResultHandler\n({resultXML,...})
Soap -> Resources: soap_resultHandler()
note over Resources: set data to resourceVO\n resourceVO.setStatus( ResourceVO.LOADED );
Resources -> ResourcesProxyResponse: RESOURCE_LOADED(resourceVO)
ResourcesProxyResponse -> ProxiesJunction: RESOURCES_PROXY_RESPONSE(message)	
	
end alt

@enduml	