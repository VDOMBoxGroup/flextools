/**
 * Created by IntelliJ IDEA.
 * User: andreev ap
 * Date: 01.02.12
 * Time: 15:34
 */
package net.vdombox.powerpack.lib.player.popup.Answers {
public class PasswordAnswer  extends TextAnswer
{
    public function PasswordAnswer( data:String )
    {
        super(data);

        textInput.displayAsPassword = true;
    }
}
}
