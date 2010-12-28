/*
	Class ActionsProxy is a wrapper over the Actions
 */
package net.vdombox.object_editor.model.proxy.componentsProxy
{
	import mx.collections.ArrayCollection;
	
	import net.vdombox.object_editor.model.vo.ActionParameterVO;
	import net.vdombox.object_editor.model.vo.ActionVO;
	import net.vdombox.object_editor.model.vo.ActionsVO;
	
	import org.puremvc.as3.interfaces.*;
	import org.puremvc.as3.patterns.proxy.Proxy;
   
    public class ActionsProxy extends Proxy implements IProxy
    {
		public static const NAME:String = "ActionsProxy";

		public function ActionsProxy ( data:Object = null ) 
        {
            super ( NAME, data );
        }
		
		public function createXML( actionsVO: ActionsVO ):XML
		{	
			var actionsXML  :XML = new XML("<Actions/>");
			var containerXML:XML = new XML("<Container/>");
			containerXML.@ID = actionsVO.container;
			actionsXML.appendChild(containerXML);
			
			var actsVO:ArrayCollection = actionsVO.actionsCollection;
			
			for each(var actObj:Object in actsVO )
			{	
				var actVO:ActionVO = actObj.data;
				var actXML:XML = new XML("<Action/>");
				actXML.@Description			= actVO.description;
				actXML.@InterfaceName		= actVO.interfaceName;
				actXML.@MethodName			= actVO.methodName;
				
				var parametersXML:XML = new XML("<Parameters/>");
				
				for each(var evParameterObj:Object in actVO.parameters )
				{	
					var actParameterVO:ActionParameterVO = evParameterObj.data;
					var parameterXML:XML = new XML("<Parameter/>");
					parameterXML.@DefaultValue	= actParameterVO.defaultValue;
					parameterXML.@Interface 	= actParameterVO.interfacePar;
					parameterXML.@InterfaceName = actParameterVO.interfaceName;					
					parameterXML.@ScriptName 	= actParameterVO.scriptName;
					parameterXML.@Help 			= actParameterVO.help;
					parameterXML.@RegularExpressionValidation = actParameterVO.regExp;
					parametersXML.appendChild( parameterXML );
				}
				actXML.appendChild( parametersXML );
				
				var sourceCodeXML:XML = XML("<SourceCode/>");
				sourceCodeXML.appendChild( XML("\n"+"<![CDATA[" + actVO.code +"]]>") )
				actXML.appendChild( sourceCodeXML );
				
				containerXML.appendChild( actXML );
			}
			return actionsXML;
		}	
		
		public function createFromXML(objTypeXML:XML):ActionsVO
		{
			var actionsVO: ActionsVO = new ActionsVO();
			var actsXML  : XML  = XML( objTypeXML.descendants("Actions") );
			actionsVO.container = actsXML.descendants("Container").@ID;
			
			//todo container			
			for each ( var actXML : XML in objTypeXML.descendants("Action") )
			{
				var actVO:ActionVO  = new ActionVO();
				actVO.description	= actXML.@Description;
				actVO.interfaceName	= actXML.@InterfaceName;
				actVO.methodName	= actXML.@MethodName;
				actVO.code			= actXML.Sourcecode;
				
				for each ( var parameterXML : XML in actXML.descendants("Parameter") )
				{
					var actParameter:ActionParameterVO = new ActionParameterVO;
					
					actParameter.defaultValue	= parameterXML.@DefaultValue;
					actParameter.interfacePar	= parameterXML.@Interface;
					actParameter.interfaceName	= parameterXML.@InterfaceName;
					actParameter.scriptName		= parameterXML.@ScriptName;
					actParameter.help			= parameterXML.@Help;
					actParameter.regExp			= parameterXML.@RegularExpressionValidation;
										
					actVO.parameters.addItem({label:actParameter.interfaceName, data:actParameter});	
				}	
				actionsVO.actionsCollection.addItem({label:actVO.interfaceName, data:actVO});
			}			
			return actionsVO;
		}
	}
}