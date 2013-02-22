package net.vdombox.components.xmldialogeditor.model.vo.components
{
	import mx.collections.ArrayCollection;
	
	import net.vdombox.components.xmldialogeditor.model.vo.OptionVO;
	import net.vdombox.components.xmldialogeditor.model.vo.attributes.AttributeIntVO;
	import net.vdombox.components.xmldialogeditor.model.vo.components.base.ComponentDrop;
	
	public class DropDownVO extends ComponentDrop
	{
		protected var _width : AttributeIntVO;
		
		public function DropDownVO(value:XML)
		{
			super(value);
			
			name = "DropDown";
			
			if ( value && value.@width[0] )
				width = new AttributeIntVO( "width", value.@width );
			else
				width = new AttributeIntVO( "width", 0 );
			
		}

		public function get width():AttributeIntVO
		{
			return _width;
		}

		public function set width(value:AttributeIntVO):void
		{
			_width = value;
		}
		
		public override function get attributes() : ArrayCollection
		{
			var _attributes : ArrayCollection = new ArrayCollection();
			
			_attributes.addItem( id );
			_attributes.addItem( visible );
			_attributes.addItem( enabled );
			_attributes.addItem( width );
			_attributes.addItem( toolTip );
			_attributes.addItem( className );
			_attributes.addItem( sort );
			_attributes.addItem( options );
			
			return _attributes;
		}
		
		public override function toXML() : XML
		{
			var xml : XML = new XML();
			xml = <DropDown></DropDown>;			
			
			xml.@id = id.value;
			xml.@visible = visible.value;
			xml.@enabled = enabled.value;
			xml.@width = width.value;
			xml.@sort = sort.value;
			xml.@['class'] = className.value;
			
			var xml2 : XML = <Properties></Properties>;
			
			xml2.appendChild( options.toXML() );
			xml2.appendChild( <Property name="toolTip">{ toolTip.value }</Property> );
			
			xml.appendChild( xml2 );
			
			return xml;
		}

	}
}