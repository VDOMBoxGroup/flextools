package net.vdombox.components.xmldialogeditor.model.vo.components
{
	import net.vdombox.components.xmldialogeditor.model.ComponentsFactory;
	import net.vdombox.components.xmldialogeditor.model.vo.attributes.AttributeBoolVO;
	import net.vdombox.components.xmldialogeditor.model.vo.attributes.AttributeIntVO;
	import net.vdombox.components.xmldialogeditor.model.vo.components.base.ComponentBase;

	public class ItemVO extends ComponentBase
	{
		private var _row : AttributeIntVO;
		private var _column : AttributeIntVO;
		private var _rowSpan : AttributeIntVO;
		private var _columnSpan : AttributeIntVO;
		private var _fullSize : AttributeBoolVO;
		 
		private var _component : ComponentBase;
		
		private var _dropState : String;
		
		public function ItemVO(value:XML = null)
		{
			super(value);
			
			name = "Item";
			
			if ( value && value.@['row'][0] )
				row = new AttributeIntVO( 'row', value.@['row'] );
			
			if ( value && value.@['column'][0] )
				column = new AttributeIntVO( 'column', value.@['column'] );
			
			if ( value && value.@['rowSpan'][0] )
				rowSpan = new AttributeIntVO( 'rowSpan', value.@['rowSpan'] );
			
			if ( value && value.@['columnSpan'][0] )
				columnSpan = new AttributeIntVO( 'columnSpan', value.@['columnSpan'] );
			
			
			if ( value && value.children().length() > 0 )
				component = ComponentsFactory.getComponentByXML( value.children()[0] );
		}

		public function get component():ComponentBase
		{
			return _component;
		}

		public function set component(value:ComponentBase):void
		{
			_component = value;
		}

		public function get row():AttributeIntVO
		{
			return _row;
		}

		public function set row(value:AttributeIntVO):void
		{
			_row = value;
		}

		public function get column():AttributeIntVO
		{
			return _column;
		}

		public function set column(value:AttributeIntVO):void
		{
			_column = value;
		}

		public function get rowSpan():AttributeIntVO
		{
			return _rowSpan;
		}

		public function set rowSpan(value:AttributeIntVO):void
		{
			_rowSpan = value;
		}

		public function get columnSpan():AttributeIntVO
		{
			return _columnSpan;
		}

		public function set columnSpan(value:AttributeIntVO):void
		{
			_columnSpan = value;
		}

		public function get fullSize():AttributeBoolVO
		{
			return _fullSize;
		}

		public function set fullSize(value:AttributeBoolVO):void
		{
			_fullSize = value;
		}

		public override function toXML() : XML
		{
			var xml : XML = new XML();
			xml = <Item></Item>;			
			
			xml.appendChild( component.toXML() );
			
			return xml;
		}
		
		public function toXMLByGrig() : XML
		{
			var xml : XML = new XML();
			
			xml = <Item></Item>;
			xml.@row = row.value;
			xml.@column = column.value;
			xml.@rowSpan = rowSpan ? rowSpan.value : 0;
			xml.@columnSpan = columnSpan ? columnSpan.value : 0;
			
			xml.appendChild( component.toXML() );
			
			return xml;
		}

		public function get dropState():String
		{
			return _dropState;
		}

		public function set dropState(value:String):void
		{
			_dropState = value;
		}

	}
}