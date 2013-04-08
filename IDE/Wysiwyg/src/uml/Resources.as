@startuml img/sequence_img001.png


box "Wisiwyg" #LightGreen 
participant TypesAccordion 	<< (M,#ADD1B2) >>
participant ResourceSelectorWindow << (M,#ADD1B2) >>
end box

box "Core" #LightBlue
participant SOAP
end box


title: Resources\n(M) - Mediator\n\n

== 1. ==
note over of TypesAccordion: load Application
loop
TypesAccordion -> SOAP: Application.LOAD_RESOURCE
	note over of SOAP: load resource to user`s file system\nin an encrypted format 
end

== 2. ==
note over of ResourceSelectorWindow: open Resource Browser
ResourceSelectorWindow -> SOAP: Application.GET_RESOURCES
SOAP --> ResourceSelectorWindow: Array of ResourceVO
	
@enduml	