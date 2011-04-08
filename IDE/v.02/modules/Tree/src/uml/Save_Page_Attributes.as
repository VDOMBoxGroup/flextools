@startuml img/sequence_img001.png

participant PropertiesPanel.mxml
participant PropertiesPanel << (M,#ADD1B2) >>

participant TreeJunction << (M,#ADD1B2) >>
box "Core" #LightBlue
	participant SOAP 
	participant Page << (P,#ADD1B2) >>
end box

title:Save Object Attributes in Tree\n\n( M ) - Mediator\n( P ) - Proxy\n 
		
			
PropertiesPanel.mxml -> PropertiesPanel: save
PropertiesPanel -> TreeJunction: SET_PAGE_ATTRIBUTES\n(vdomObjectAttributesVO)

TreeJunction -> SOAP: junction.sendMessage(...)
	
' SOAP -> SOAP: operationResultHandler'
SOAP -> Page: soap_resultHandler\n("set_attributes")

Page -> TreeElement: PAGE_ATTRIBUTES_SETTED\n({ pageVO, \n   vdomObjectAttributesVO })
note over of TreeElement: set vdomObjectAttributesVO

@enduml	