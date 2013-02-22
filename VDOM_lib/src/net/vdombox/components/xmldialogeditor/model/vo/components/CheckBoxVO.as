package net.vdombox.components.xmldialogeditor.model.vo.components
{
	import mx.collections.ArrayCollection;
	
	import net.vdombox.components.xmldialogeditor.model.vo.attributes.AttributeBoolVO;
	import net.vdombox.components.xmldialogeditor.model.vo.attributes.AttributeStringVO;
	import net.vdombox.components.xmldialogeditor.model.vo.components.base.ComponentAddition;
	
	public class CheckBoxVO extends ComponentAddition
	{		
		protected var _checked : AttributeBoolVO;
		protected var _text : AttributeStringVO;
		
		public function CheckBoxVO(value:XML = null)
		{
			super(value);
			
			name = "CheckBox";
			
			if ( value && value.@checked[0] && value.@checked == "true" )
				checked = new AttributeBoolVO( "checked", true );
			else
				checked = new AttributeBoolVO( "checked", false );
			
			if ( value && value.hasOwnProperty( "Properties" ) )
			{
				var propertyList : XMLList = value.Properties[0].children();
				
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
							
						default:
						{
							break;
						}
					}
				}
			}
			
			if ( !text )
				text = new AttributeStringVO( 'text', "CheckBox" );
		}
		
		[Bindable]
		public function get checked():AttributeBoolVO
		{
			return _checked;
		}
		
		public function set checked(value:AttributeBoolVO):void
		{
			_checked = value;
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
			_attributes.addItem( checked );
			_attributes.addItem( className );
			_attributes.addItem( toolTip );
			_attributes.addItem( text );
			
			return _attributes;
		}
		
		public override function toXML() : XML
		{
			var xml : XML = new XML();
			xml = <CheckBox>
				
			<Properties>
				<Property name="text">{ text.value }</Property>
				<Property name="toolTip">{ toolTip.value }</Property>
			</Properties>
			
			</CheckBox>;			
			
			xml.@id = id.value;
			xml.@visible = visible.value;
			xml.@enabled = enabled.value;
			xml.@checked = checked.value;
			xml.@['class'] = className.value;
			
			return xml;
		}
	}
}