package net.vdombox.ide.modules.dataBase.interfaces
{
	public interface ISearchable
	{
		/**
		 * Flag indicating if last search ended successfully <code>true</code> or not <code>false</code>.
		 */
		[Bindable("searchResultChanged")]
		function get found():Boolean;
		
		/**
		 * String wildcard used in last search.
		 * <p>This should equal to the string passed to the <code>find()</code> function.</p>
		 */ 
		[Bindable("searchParamsChanged")]
		function get searchString():String;
		
		/**		
		 * String wildcard converted to the regular expression (RegExp).
		 */
		[Bindable("searchParamsChanged")]
		function get searchExpression():RegExp;
		
		/**
		 * Find the given wildcard in the component.
		 * 
		 * <p>Search the component for text wildcard passed <code>wildcard</code> 
		 * and return boolean value determining if something was found. 
		 * The wildcard should interpret <code>"*"</code> character as matching any string
		 * and <code>"?"</code> character as matching any single character.</p>
		 * 
		 * <p>Component may change its state after call to this function so that additional information
		 * about what was found can be accessed</p>
		 * 
		 * @param wildcard text to search for
		 * @param caseInsensitive flag indicating whether search should be case insensitive
		 * @return <code>true</code> if text was fond or <code>false</code> if not
		 */
		function find(wildcard:String, caseInsensitive:Boolean = true):Boolean;
		
		/**
		 * Find next match using parameters specified in last call to <code>found()</code> function.
		 */
		function findNext():Boolean;
		
		/**
		 * Find previous match using parameters specified in last call to <code>found()</code> function.
		 */
		function findPrevious():Boolean;

	}
}