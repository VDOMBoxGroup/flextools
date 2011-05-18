/*
	Class ActionsProxy is a wrapper over the Actions
 */
package net.vdombox.object_editor.model.proxy.componentsProxy
{
	import mx.collections.ArrayCollection;
	
	import net.vdombox.object_editor.model.ErrorLogger;
	import net.vdombox.object_editor.model.vo.ActionParameterVO;
	import net.vdombox.object_editor.model.vo.ActionVO;
	import net.vdombox.object_editor.model.vo.ActionsContainerVO;
	
	import org.puremvc.as3.interfaces.*;
	import org.puremvc.as3.patterns.proxy.Proxy;
   
    public class ActionContainersProxy extends Proxy implements IProxy
    {
		public static const NAME:String = "ActionsProxy";

		public function ActionContainersProxy ( data:Object = null ) 
        {
            super ( NAME, data );
        }
		
		public function createXML( actionContainersVO: ArrayCollection ):XML
		{			
			var actionsXML  :XML = <Actions/>;
			for each (var actContObj:Object in actionContainersVO)
			{				
				var actContsVO: ActionsContainerVO = actContObj.data;
				var containerXML:XML = <Container/>;
				containerXML.@ID = actContsVO.containerID;
				actionsXML.appendChild(containerXML);
				
				var actsVO:ArrayCollection = actContsVO.actionsCollection;
				
				for each (var actObj:Object in actsVO)
				{	
					var actVO:ActionVO = actObj.data;
					var actXML:XML = <Action/>;
					actXML.@Description			= actVO.description;
					actXML.@InterfaceName		= actVO.interfaceName;
					actXML.@MethodName			= actVO.methodName;
					
					var parametersXML:XML = <Parameters/>;
					
					for each (var evParameterObj:Object in actVO.parameters)
					{	
						var actParameterVO:ActionParameterVO = evParameterObj.data;
						var parameterXML:XML = <Parameter/>;
						parameterXML.@DefaultValue	= actParameterVO.defaultValue;
						parameterXML.@Interface 	= actParameterVO.interfacePar;
						parameterXML.@InterfaceName = actParameterVO.interfaceName;					
						parameterXML.@ScriptName 	= actParameterVO.scriptName;
						parameterXML.@Help 			= actParameterVO.help;
						parameterXML.@RegularExpressionValidation = actParameterVO.regExp;
						parametersXML.appendChild( parameterXML );
					}
					actXML.appendChild( parametersXML );
					
					var sourceCodeXML:XML = <SourceCode/>;
					sourceCodeXML.appendChild( XML("\n"+"<![CDATA[" + actVO.code +"]]>") )
					actXML.appendChild( sourceCodeXML );
					
					containerXML.appendChild( actXML );
				}
			}
			return actionsXML;
		}	
				
		public function createFromXML(objTypeXML:XML):ArrayCollection
		{
			var actionContainersCollection:ArrayCollection = new ArrayCollection();
			try
			{
				var actsXML: XML = XML( objTypeXML.descendants("Actions") );
						
				for each (var contXML : XML in actsXML.descendants("Container"))
				{
					var actsContainerVO: ActionsContainerVO = new ActionsContainerVO();
					actsContainerVO.containerID = contXML.@ID;
										
					for each (var actXML : XML in contXML.descendants("Action"))
					{
						var actVO:ActionVO  = new ActionVO();
						actVO.description	= actXML.@Description;
						actVO.interfaceName	= actXML.@InterfaceName;
						actVO.methodName	= actXML.@MethodName;
						actVO.code			= getSourceCode(actXML);
						
						for each (var parameterXML : XML in actXML.descendants("Parameter"))
						{
							var actParameter:ActionParameterVO = new ActionParameterVO;
							
							actParameter.defaultValue	= parameterXML.@DefaultValue;
							actParameter.interfacePar	= parameterXML.@Interface;
							actParameter.interfaceName	= parameterXML.@InterfaceName;
							actParameter.scriptName		= parameterXML.@ScriptName;
							actParameter.help			= parameterXML.@Help;
							actParameter.regExp			= parameterXML.@RegularExpressionValidation;
												
							actVO.parameters.addItem({label:actParameter.scriptName, data:actParameter});	
						}	
						actsContainerVO.actionsCollection.addItem({label:actVO.methodName, data:actVO});
					}
					actionContainersCollection.addItem({label:actsContainerVO.containerID, data:actsContainerVO});
				}
						
			}
			catch(error:TypeError)
			{	
				ErrorLogger.instance.logError("Failed: not teg: <Actions>", "ActionContainersProxy.createFromXML()");
			}
			finally
			{
				return actionContainersCollection;
			}
		}
		
		private function getSourceCode( actXML: XML):String
		{
			//return (actXML.SourceCode.toString() == "")? actXML.sourcecode.toString(): actXML.SourceCode.toString();
			if ( actXML.SourceCode.toString() != "" )
				return actXML.SourceCode.toString();
			
			else if ( actXML.sourcecode.toString() != "" )
				return actXML.sourcecode.toString();
			
			else if ( actXML.Sourcecode.toString() != "" )
				return actXML.Sourcecode.toString();
			
			else if ( actXML.sourceCode.toString() != "" )
				return actXML.sourceCode.toString();
			
			return "";
		}
	}	
}