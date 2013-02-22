package net.vdombox.components.xmldialogeditor.model.vo.components
{
	import mx.collections.ArrayCollection;
	
	import net.vdombox.components.xmldialogeditor.model.vo.attributes.AttributeEnumVO;
	import net.vdombox.components.xmldialogeditor.model.vo.attributes.AttributeStringVO;
	import net.vdombox.components.xmldialogeditor.model.vo.components.base.ComponentAddition;
	
	public class ButtonVO extends ComponentAddition
	{
		private var _type : AttributeEnumVO;
		protected var _text : AttributeStringVO;
		
		private var _imageUrl : AttributeStringVO;
		private var _imageBase64 : AttributeStringVO;
		
		public function ButtonVO(value:XML = null)
		{
			super( value );
			
			name = "Button";
			
			if ( value && value.@type[0] )
				type = new AttributeEnumVO("type", value.@type, ["", "submit", "cancel", "reset", "common"] );
			else
				type = new AttributeEnumVO("type", "", ["", "submit", "cancel", "reset", "common"] );
			
			if ( value && value.hasOwnProperty( "Properties" ) )
			{
				var propertyList : XMLList = value.Properties[0]..Property;
				
				for each ( var property : XML in propertyList )
				{
					var name : String = property.@name[0];
					
					switch(name)
					{
						case "text":
						{
							text =  new AttributeStringVO( 'text', property.toString() );
							break;
						}
						
						case "imageUrl":
						{
							imageUrl = new AttributeStringVO( "imageUrl", property.toString() );
							break;
						}
							
						case "imageBase64":
						{
							imageBase64 = new AttributeStringVO( "imageBase64", property.toString() );;
							break;
						}
							
						default:
						{
							break;
						}
					}
				}
			}
			
			if ( !text )
				text = new AttributeStringVO( 'text', "Button" );
			
			if ( !imageUrl )
				imageUrl = new AttributeStringVO( 'imageUrl', "" );
			
			if ( !imageBase64 )
				imageBase64 = new AttributeStringVO( 'imageBase64', "" );
		}

		public function get type():AttributeEnumVO
		{
			return _type;
		}

		public function set type(value:AttributeEnumVO):void
		{
			_type = value;
		}

		public function get imageUrl():AttributeStringVO
		{
			return _imageUrl;
		}

		public function set imageUrl(value:AttributeStringVO):void
		{
			_imageUrl = value;
		}

		public function get imageBase64():AttributeStringVO
		{
			return _imageBase64;
		}

		public function set imageBase64(value:AttributeStringVO):void
		{
			_imageBase64 = value;
		}

		[Bindable]
		public function get text():AttributeStringVO
		{
			return _text;
		}

		public function set text(value:AttributeStringVO):void
		{
			_text = value;
		}

		public override function get attributes() : ArrayCollection
		{
			var _attributes : ArrayCollection = new ArrayCollection();
			
			_attributes.addItem( id );
			_attributes.addItem( visible );
			_attributes.addItem( enabled );
			_attributes.addItem( type );
			_attributes.addItem( toolTip );
			_attributes.addItem( text );
			_attributes.addItem( imageUrl );
			_attributes.addItem( imageBase64 );
			_attributes.addItem( className );
			
			return _attributes;
		}
		
		public override function toXML() : XML
		{
			var xml : XML = new XML();
			xml = <Button>
				
			<Properties>
				<Property name="text">{ text.value }</Property>
				<Property name="toolTip">{ toolTip.value }</Property>
				<Property name="imageUrl">{ imageUrl.value }</Property>\
				<Property name="imageBase64">{ imageBase64.value }</Property>
			</Properties>
			
			</Button>;			
			
			xml.@id = id.value;
			xml.@type = type.value;
			xml.@visible = visible.value;
			xml.@enabled = enabled.value;
			xml.@['class'] = className.value;
			
			return xml;
		}
	}
}