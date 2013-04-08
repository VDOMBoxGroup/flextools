@startuml img/sequence_img001.png

participant WysiwygGetted << (C,#ADD1B2) >>
	
participant Render << (P,#ADD1B2) >>
participant VdomObjectEditor << (M,#ADD1B2) >>
		
			

	
	
title:Creating RenderBase proces  \n\n( M ) - Mediator\n( C ) - Command\n( P ) - Proxy

WysiwygGetted -> Render: generateRenderVO\n( vdomObjectVO, wysiwygXML )\n:RenderVO

Render -> Render : renderVO = \nnew RenderVO\n( vdomObjectVO );
Render -> Render : createAttributes\n(renderVO, rawRenderData );
note over of Render: Runs recursively:
Render -> Render : createChildren\n( renderVO, rawRenderData );

WysiwygGetted -> VdomObjectEditor: editorVO
VdomObjectEditor -> editorVO: renderVO = renderVO
editorVO -> VdomObjectEditor.MXML : renderVOChanged\n( RenderVO )
VdomObjectEditor.MXML -> PageRenderer: set: renderVO 
PageRenderer -> Render: renderer_renderchangingHandler()\nRENDER_CHANGING
PageRenderer -> Render: renderer_renderchangedHandler()\nRENDER_CHANGED 
	
	
	
	
@enduml	