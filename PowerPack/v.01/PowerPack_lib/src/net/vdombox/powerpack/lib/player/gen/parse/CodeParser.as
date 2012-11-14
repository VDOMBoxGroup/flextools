package net.vdombox.powerpack.lib.player.gen.parse
{

import mx.core.Application;

import net.vdombox.powerpack.lib.player.events.CodeParserEvent;
import net.vdombox.powerpack.lib.extendedapi.utils.Utils;
import net.vdombox.powerpack.lib.player.gen.*;
import net.vdombox.powerpack.lib.player.gen.errorClasses.ValidationError;
import net.vdombox.powerpack.lib.player.gen.parse.parseClasses.CodeFragment;
import net.vdombox.powerpack.lib.player.gen.parse.parseClasses.LexemStruct;
import net.vdombox.powerpack.lib.player.gen.parse.parseClasses.ParsedBlock;


public class CodeParser
{
	public static const MSG_NN_SYNTAX_ERR : String = "Normal state syntax error.";
	public static const MSG_SN_SYNTAX_ERR : String = "Subgraph state syntax error.";
	public static const MSG_CN_SYNTAX_ERR : String = "Command state syntax error.";
	public static const MSG_CN_UNKNOWN_TYPE : String = "Unrecognized command state type.";

	public static function evaluateLexem( lexem : LexemStruct, contexts : Array ) : void
	{
		switch ( LexemStruct( lexem ).type )
		{
			case 'v':
				lexem.code = String( lexem.origValue ).substring( 1 );
				lexem.value = Parser.eval( lexem.code, contexts );
				break;

			case 't':
				lexem.value = Utils.replaceEscapeSequences( lexem.origValue.toString(), "\\r" );
				lexem.value = Utils.replaceEscapeSequences( lexem.value.toString(), "\\n" );
				lexem.value = Utils.replaceEscapeSequences( lexem.value.toString(), "\\t" );
				lexem.value = Utils.replaceEscapeSequences( lexem.value.toString(), "\\$" );
				lexem.value = Utils.replaceEscapeSequences( lexem.value.toString(), "\\\\" );
				lexem.code = lexem.value;
				break;

			case '[':
			case ']':
			case '{':
			case '}':
			case ';':
				lexem.value = '';
				lexem.code = lexem.value;
				break;
		}
	}

	public static function executeCodeFragment( fragment : CodeFragment, contexts : Array, // execution contexts
												stepReturn : Boolean = false, // stops after every fragment execution
												evaluate : Boolean = false		// evaluate lists value
			) : void
	{
		// validate

		if ( !fragment.validated )
		{
			Parser.validateCodeFragment( fragment );
		}

		if ( fragment.errFragment || !fragment.validated )
			return;

		if ( fragment.executed )
			return;

		// execute subfragments
		var codeParserEvent : CodeParserEvent = new CodeParserEvent(CodeParserEvent.EXECUTE_CODE_FRAGMENT);
		codeParserEvent.fragmentValue = fragment.origValue;
		Application.application.dispatchEvent(codeParserEvent);
		
		var subfragment : Object;
		for ( var i : int = fragment.current; i < fragment.fragments.length; i++ )
		{
			subfragment = fragment.fragments[i];
			if ( subfragment is CodeFragment && (fragment.ctype != CodeFragment.CT_LIST || evaluate) )
			{
				executeCodeFragment( subfragment as CodeFragment, contexts, stepReturn, evaluate );

				if ( CodeFragment( subfragment ).executed )
					fragment.current = i + 1;

				if ( fragment.lastExecutedFragment.ctype == CodeFragment.CT_FUNCTION &&
						(stepReturn || fragment.lastExecutedFragment.retValue is Function) )
					return;
			}
			else if ( subfragment is LexemStruct )
			{
				evaluateLexem( subfragment as LexemStruct, contexts );
				fragment.current = i + 1;
			}
		}

		// generate executable code

		var code : String = '';
		var tmpValue : Object;

		switch ( fragment.ctype )
		{
			case CodeFragment.CT_TEXT:
				for ( i = 0; i < fragment.fragments.length; i++ )
				{
					subfragment = fragment.fragments[i];

					if ( subfragment is CodeFragment )
						tmpValue = (subfragment as CodeFragment).retValue;
					else if ( subfragment is LexemStruct )
						tmpValue = LexemStruct( subfragment ).value;

					if ( tmpValue == null )
						tmpValue = 'undefined';

					code += tmpValue.toString();
				}

				fragment.retValue = code;
				fragment.lastExecutedFragment = fragment;
				fragment.executed = true;
				return;

				break;

			case CodeFragment.CT_OPERATION:
			case CodeFragment.CT_TEST:
				for ( i = 0; i < fragment.fragments.length; i++ )
				{
					subfragment = fragment.fragments[i];

					if ( subfragment is CodeFragment )
						tmpValue = (subfragment as CodeFragment).retVarName;
					else if ( subfragment is LexemStruct )
						tmpValue = LexemStruct( subfragment ).code;

					if ( tmpValue == null )
						tmpValue = 'null';

					code += tmpValue.toString();
				}
				break;

			case CodeFragment.CT_ADV_VAR:
				for ( i = 1; i < fragment.fragments.length - 1; i++ )
				{
					subfragment = fragment.fragments[i];

					if ( subfragment is CodeFragment )
						tmpValue = (subfragment as CodeFragment).retVarName;
					else if ( subfragment is LexemStruct )
						tmpValue = LexemStruct( subfragment ).code;

					if ( tmpValue == null )
						tmpValue = 'null';

					code += tmpValue.toString();
				}
				code = Parser.eval( code, contexts );
				fragment.varNames.push( code );
				break;

			case CodeFragment.CT_FUNCTION:
				Parser.processOperationGroups( fragment.fragments );

				for ( i = 2; i < fragment.fragments.length - 1; i++ )
				{
					subfragment = fragment.fragments[i];

					if ( subfragment is CodeFragment )
						tmpValue = (subfragment as CodeFragment).retVarName;
					else if ( subfragment is LexemStruct )
						tmpValue = LexemStruct( subfragment ).code;

					if ( tmpValue == null )
						tmpValue = 'null';

					var sep : String =
							(fragment.fragments[i - 1].operationGroup != fragment.fragments[i].operationGroup &&
									code.length && tmpValue.toString().length ? "," : "");

					code += sep + tmpValue.toString();
				}

				code = TemplateStruct.CNTXT_INSTANCE + "." +
						fragment.funcName + "(" + code + ")";
				break;

			case CodeFragment.CT_ASSIGN:
				for ( i = 0; i < fragment.fragments.length - 1; i += 2 )
				{
					subfragment = fragment.fragments[i];
					var nextSubfragment : Object = fragment.fragments[i + 1];

					if ( nextSubfragment is LexemStruct && LexemStruct( nextSubfragment ).type == '=' )
					{
						if ( subfragment is CodeFragment )
							tmpValue = (subfragment as CodeFragment).varNames[0];
						else if ( subfragment is LexemStruct )
							tmpValue = LexemStruct( subfragment ).code;

						if ( tmpValue == null )
							tmpValue = 'null';

						// add prefix
						tmpValue = fragment.varPrefix + tmpValue.toString();
						fragment.varNames.push( tmpValue );

						code += tmpValue + '=';
					}
					else
						break;
				}

				// add rest of code

				var fragmCount : int = 0;
				var memSubfragm : CodeFragment;
				for ( var j : int = i; j < fragment.fragments.length; j++ )
				{
					subfragment = fragment.fragments[j];

					if ( subfragment is CodeFragment )
					{
						tmpValue = (subfragment as CodeFragment).retVarName;
						memSubfragm = (subfragment as CodeFragment);
					}
					else if ( subfragment is LexemStruct )
						tmpValue = LexemStruct( subfragment ).code;

					if ( tmpValue == null )
						tmpValue = 'null';

					if ( tmpValue )
						fragmCount++;

					code += tmpValue;
				}
				// get transition from subfragment
				if ( memSubfragm && fragmCount == 1 )
				{
					fragment.transition = memSubfragm.transition;
				}

				break;

			case CodeFragment.CT_LIST:
				if ( !evaluate )
				{
					tmpValue = Utils.quotes( fragment.origValue );
				}
				else
				{
					tmpValue = Utils.quotes( fragment.evalValue );
				}

				code = tmpValue.toString();
				break;
		}

		// execute generated code
		fragment.retValue = Parser.eval( code, contexts );
		contexts[0][fragment.retVarName] = fragment.retValue;

		for ( i = fragment.current; i < fragment.fragments.length; i++ )
		{
			subfragment = fragment.fragments[i];
			if ( subfragment is CodeFragment )
			{
				delete contexts[0][subfragment.retVarName];
			}
		}

		fragment.executed = true;
		fragment.lastExecutedFragment = fragment;
	}

	public static function executeBlock( block : ParsedBlock, contexts : Array, stepReturn : Boolean = false ) : void
	{
		// validate

		if ( !block.validated )
		{
			Parser.validateFragmentedBlock( block );
		}

		if ( block.errFragment || !block.validated )
			return;

		if ( block.executed )
			return;

		while ( block.current < block.fragments.length )
		{
			var curFragment : CodeFragment = block.fragments[block.current];

			executeCodeFragment( curFragment, contexts, stepReturn );

			if ( curFragment.executed )
				block.current++;

			if ( stepReturn && block.current < block.fragments.length )
				return;
		}

		block.executed = true;
	}

	/**
	 *
	 * @param text
	 * @param contexts
	 * @return
			*
	 */
	public static function ParseText( text : String, contexts : Array = null ) : ParsedBlock
	{
		var block : ParsedBlock = Parser.fragmentLexems( Parser.getLexemArray( text.concat(), false ), 'text' );

		if ( block.errFragment )
			return block;

		Parser.validateFragmentedBlock( block );

		if ( block.errFragment )
			return block;

		if ( contexts )
		{
			executeBlock( block, contexts );
		}

		return block;
	}

	/**
	 *
	 * @param nodeText
	 * @return
			*
	 */
	public static function ParseSubgraphNode( nodeText : String ) : ParsedBlock
	{
		var pattern : RegExp;
		var str  : String = nodeText.concat();
		var block : ParsedBlock = new ParsedBlock();

		pattern = /[\W]/gi;
		block.retValue = str;

		if ( !str || pattern.test( str ))
		{
			block.error = new ValidationError( MSG_SN_SYNTAX_ERR );
		}

		block.executed = true;
		return block;
	}

	/**
	 *
	 * @param code
	 * @return
			*
	 */
	public static function ParseCode( code : String ) : ParsedBlock
	{
		var block : ParsedBlock = Parser.fragmentLexems( Parser.getLexemArray( code.concat(), true ), 'code' );

		if ( block.errFragment )
			return block;

		Parser.validateFragmentedBlock( block );

		if ( block.errFragment )
			return block;

		return block;
	}

}
}