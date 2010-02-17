package net.vdombox.ide.common.vo
{
	public class ApplicationInformationVO
	{
		public var name : String

		public var description : String

		public var iconID : String

		public var indexPageID : String
		
		public var scriptingLanguage : String

		public function toXML() : XML
		{
			var info : XML =
				<Attributes/>

			if ( name !== null )
				info.appendChild(
					<Name>{name}</Name>
					);

			if ( description !== null )
				info.appendChild(
					<Description>{description}</Description>
					);

			if ( iconID !== null )
				info.appendChild(
					<Icon>{iconID}</Icon>
					);

			if ( indexPageID !== null )
				info.appendChild(
					<Index>{indexPageID}</Index>
					);
			
			if ( scriptingLanguage !== null )
				info.appendChild(
					<ScriptingLanguage>{scriptingLanguage}</ScriptingLanguage>
				);
			
			return info;
		}
	}
}