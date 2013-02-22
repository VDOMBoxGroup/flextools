package net.vdombox.components.xmldialogeditor.model.vo.components
{
	import mx.collections.ArrayCollection;
	
	import net.vdombox.components.xmldialogeditor.model.vo.attributes.AttributeIntVO;
	import net.vdombox.components.xmldialogeditor.model.vo.components.base.ComponentText;

	public class TextBoxVO extends ComponentText
	{
		protected var _maxLength : AttributeIntVO;
		
		
		public function TextBoxVO( value:XML )
		{
			super(value);
			
			name = "TextBox";
			
			if ( value && value.@maxLength[0] )
				maxLength = new AttributeIntVO("maxLength", value.@maxLength );
			else
				maxLength = new AttributeIntVO("maxLength", 0);
			
		}

		public function get maxLength():AttributeIntVO
		{
			return _maxLength;
		}
		
		public function set maxLength(value:AttributeIntVO):void
		{
			_maxLength = value;
		}
		
		public override function get attributes() : ArrayCollection
		{
			
			var _attributes : ArrayCollection = new ArrayCollection();
			
			_attributes.addItem( id );
			_attributes.addItem( visible );
			_attributes.addItem( enabled );
			_attributes.addItem( toolTip );
			_attributes.addItem( className );
			_attributes.addItem( width );
			_attributes.addItem( placeHolder );
			_attributes.addItem( text );
			_attributes.addItem( maxLength );
			
			return _attributes;
		}
		
		public override function toXML() : XML
		{
			var xml : XML = new XML();
			xml = <TextBox>
				
			<Properties>
				<Property name="text">{ text.value }</Property>
				<Property name="toolTip">{ toolTip.value }</Property>
				<Property name="placeHolder">{ placeHolder.value }</Property>
			</Properties>
			
			</TextBox>;			
			
			xml.@id = id.value;
			xml.@visible = visible.value;
			xml.@enabled = enabled.value;
			xml.@width = width.value;
			xml.@maxLength = maxLength.value;
			xml.@['class'] = className.value;
			
			return xml;
		}
	}
}