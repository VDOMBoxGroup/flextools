package net.vdombox.components.xmldialogeditor.model.vo.components
{
	import mx.collections.ArrayCollection;
	
	import net.vdombox.components.xmldialogeditor.model.vo.attributes.AttributeIntVO;
	import net.vdombox.components.xmldialogeditor.model.vo.components.base.ComponentText;
	
	public class TextAreaVO extends ComponentText
	{
		private var _height : AttributeIntVO;
		
		public function TextAreaVO(value:XML)
		{
			super(value);
			
			name = "TextArea";
			
			if ( value && value.@maxLength[0] )
				height = new AttributeIntVO("height", value.@height );
			else
				height = new AttributeIntVO("height", 0);
		}

		public function get height():AttributeIntVO
		{
			return _height;
		}

		public function set height(value:AttributeIntVO):void
		{
			_height = value;
		}
		
		public override function get attributes() : ArrayCollection
		{
			
			var _attributes : ArrayCollection = new ArrayCollection();
			
			_attributes.addItem( id );
			_attributes.addItem( visible );
			_attributes.addItem( enabled );
			_attributes.addItem( width );
			_attributes.addItem( height );
			_attributes.addItem( toolTip );
			_attributes.addItem( placeHolder );
			_attributes.addItem( text );
			_attributes.addItem( className );
			
			return _attributes;
		}
		
		public override function toXML() : XML
		{
			var xml : XML = new XML();
			xml = <TextArea>
				
			<Properties>
				<Property name="text">{ text.value }</Property>
				<Property name="toolTip">{ toolTip.value }</Property>
				<Property name="placeHolder">{ placeHolder.value }</Property>
			</Properties>
			
			</TextArea>;			
			
			xml.@id = id.value;
			xml.@visible = visible.value;
			xml.@enabled = enabled.value;
			xml.@width = width.value;
			xml.@height = height.value;
			xml.@['class'] = className.value;
			
			return xml;
		}

	}
}