package net.vdombox.components.xmldialogeditor.model.vo.components
{
	import mx.collections.ArrayCollection;
	
	import net.vdombox.components.xmldialogeditor.model.vo.attributes.AttributeEnumVO;
	import net.vdombox.components.xmldialogeditor.model.vo.attributes.AttributeStringVO;
	import net.vdombox.components.xmldialogeditor.model.vo.components.base.ComponentGroup;

	public class CheckBoxGroupVO extends ComponentGroup
	{
		
		public function CheckBoxGroupVO(value:XML)
		{
			super(value);
			
			name = "CheckBoxGroup";
			
			if ( !title )
				title = new AttributeStringVO( 'title', "CheckBoxGroup" );
		}
		
		public override function get attributes() : ArrayCollection
		{
			var _attributes : ArrayCollection = new ArrayCollection();
			
			_attributes.addItem( id );
			_attributes.addItem( visible );
			_attributes.addItem( enabled );
			_attributes.addItem( sort );
			_attributes.addItem( layout );
			_attributes.addItem( title );
			_attributes.addItem( toolTip );
			_attributes.addItem( className );
			_attributes.addItem( options );
			
			return _attributes;
		}
		
		public override function toXML() : XML
		{
			var xml : XML = new XML();
			xml = <CheckBoxGroup></CheckBoxGroup>;			
			
			xml.@id = id.value;
			xml.@visible = visible.value;
			xml.@enabled = enabled.value;
			xml.@layout = layout.value;
			xml.@sort = sort.value;
			xml.@['class'] = className.value;
			
			var xml2 : XML = <Properties></Properties>;
			
			xml2.appendChild( options.toXML() );
			xml2.appendChild( <Property name="title">{ title.value }</Property> );
			xml2.appendChild( <Property name="toolTip">{ toolTip.value }</Property> );
			
			xml.appendChild( xml2 );
			
			return xml;
		}
		
	}
}