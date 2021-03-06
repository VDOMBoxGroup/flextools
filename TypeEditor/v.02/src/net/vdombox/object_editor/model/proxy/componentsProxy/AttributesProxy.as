/*
	Class AtributesProxy is a wrapper over the Atributes
 */
package net.vdombox.object_editor.model.proxy.componentsProxy
{
import flash.filesystem.File;

import mx.collections.ArrayCollection;

import net.vdombox.object_editor.Utils.StringUtils;

import net.vdombox.object_editor.model.ErrorLogger;
import net.vdombox.object_editor.model.proxy.FileProxy;
import net.vdombox.object_editor.model.proxy.LaTexProxy;
import net.vdombox.object_editor.model.vo.AttributeVO;
import net.vdombox.object_editor.model.vo.ObjectTypeVO;
	
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
   
    public class AttributesProxy extends Proxy implements IProxy
    {
		public static const NAME:String = "AttributesProxy";

		public function AttributesProxy ( data:Object = null ) 
        {
            super ( NAME, data );
        }
		
		public function createXML( attributesVO: ArrayCollection ):XML
		{		
			var attribsXML:XML = <Attributes/>;		
			
			for each (var obj:Object in attributesVO)
			{	
				var attribVO:AttributeVO = obj.data;
				var attrXML:XML = <Attribute/>;
				attrXML.Name			= attribVO.name;
				attrXML.DisplayName		= attribVO.displayName;
				attrXML.DefaultValue	= attribVO.defaultValue;	
				attrXML.Visible			= (attribVO.visible)? "1": "0";	
				attrXML.Help			= attribVO.help;
				attrXML.InterfaceType	= attribVO.interfaceType;
				attrXML.CodeInterface	= attribVO.codeInterface;
				attrXML.CodeInterface	= attribVO.codeInterface.replace("Number1", "Number");
				attrXML.Colorgroup		= attribVO.colorgroup;
				attrXML.ErrorValidationMessage		= attribVO.errorValidationMessage;
				attrXML.RegularExpressionValidation	= attribVO.regularExpressionValidation;
				attribsXML.appendChild(attrXML);
			}
			return attribsXML;
		}	
		
		public function createFromXML(objTypeXML:XML):ArrayCollection
		{
			var atributesCollection:ArrayCollection = new ArrayCollection();
			
			try
			{
				for each (var attrinuteXML : XML in objTypeXML.descendants("Attribute"))
				{
					var attrib:AttributeVO = new AttributeVO;
					
					attrib.name			= attrinuteXML.Name;
					attrib.displayName	= attrinuteXML.DisplayName;
					attrib.defaultValue	= attrinuteXML.DefaultValue;
					attrib.visible		= attrinuteXML.Visible.toString() == "1";
					attrib.help			=  StringUtils.getValueFromXML(attrinuteXML, ["Help", "Description" ]).toString();
					attrib.interfaceType	= attrinuteXML.InterfaceType;
					attrib.codeInterface	= attrinuteXML.CodeInterface;
					attrib.colorgroup	= parseInt(StringUtils.getValueFromXML(attrinuteXML, ["ColorGroup", "Colorgroup"]).toString());
					attrib.errorValidationMessage		= attrinuteXML.ErrorValidationMessage;
					attrib.regularExpressionValidation	= attrinuteXML.RegularExpressionValidation;
					
					atributesCollection.addItem({label:attrib.name, color:attrib.colorgroup, data:attrib});	
				}	
			}		
			catch(error:TypeError)
			{	
				ErrorLogger.instance.logError("Failed: did not teg: <Attribute>", "AttributesProxy.createFromXML()");
			}
			finally
			{
				return atributesCollection;
			}
		}

        private function get languagesProxy() : LanguagesProxy
        {
            return facade.retrieveProxy(LanguagesProxy.NAME) as LanguagesProxy;
        }

        private function get laTexProxy() : LaTexProxy
        {
            return facade.retrieveProxy(LaTexProxy.NAME) as LaTexProxy;
        }

        private function get fileProxy() : FileProxy
        {
            return facade.retrieveProxy(FileProxy.NAME) as FileProxy;
        }


	}
}