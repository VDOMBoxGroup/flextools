package net.vdombox.ide.common.model._vo
{

	/**
	 * The ApplicationInformationVO is Visual Object of VDOM Application.
	 * ApplicationInformation is contained in VDOM Application.
	 */
	public class ApplicationInformationVO
	{
		public var name : String

		public var description : String

		public var iconID : String

		public var indexPageID : String

		public var scriptingLanguage : String

		public var active : String = "1"

		public var version : String;


		public function toXML() : XML
		{
			var info : XML = <Attributes/>

			if ( name !== null )
				info.appendChild( <Name>{name}</Name> );

			if ( description !== null )
				info.appendChild( <Description>{description}</Description> );

			if ( iconID !== null )
				info.appendChild( <Icon>{iconID}</Icon> );

			if ( indexPageID !== null )
				info.appendChild( <Index>{indexPageID}</Index> );

			if ( scriptingLanguage !== null )
				info.appendChild( <ScriptingLanguage>{scriptingLanguage}</ScriptingLanguage> );

			if ( version !== null && version !== "" )
				info.appendChild( <Version>{version}</Version> );

			info.appendChild( <Active>{active}</Active> );

			return info;
		}
	}
}
