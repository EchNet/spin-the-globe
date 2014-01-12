package com.kayak.events
{
    import flash.events.Event;
    
    /**
     * A command dispatched through the AS event system.
     */
    public class CommandEvent
        extends Event
    {
        /**
         * All commands are of one event type.
         */
        public static const COMMAND_TYPE:String = "command";

        public var command:String;

        public var payload:Object;

        /**
         * Constructor.
         */
        public function CommandEvent (cmd:String, payload:Object = null)
        {
            super(COMMAND_TYPE);
            this.command = cmd;
            this.payload = payload;
        }

        /**
         * Create a copy of this object.  Required by ActionScript event
         * system.
         */
        override public function clone():Event
        {
            return new CommandEvent (command, payload);
        }
    }
}
