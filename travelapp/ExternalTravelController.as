package
{
    import com.kayak.events.CommandEvent;
    import com.kayak.events.ExternalEventBridge;
    import com.kayak.globe.GlobeView;
    import flash.display.DisplayObject;
    import flash.events.Event;

    /**
     * A TravelController that communicates with the external Javascript
     * environment via the ExternalEventBridge.
     */
    public class ExternalTravelController extends TravelController
    {
        /**
         * Constructor.
         */
        public function ExternalTravelController(globe:GlobeView,
                                                 parent:DisplayObject)
        {
            super(globe, parent);

            addEventListener(START_MOTION,
                ExternalEventBridge.instance.dispatchExternalEvent);

            addEventListener(STOP_MOTION,
                ExternalEventBridge.instance.dispatchExternalEvent);

            ExternalEventBridge.instance.addEventListener(
                CommandEvent.COMMAND_TYPE, handleCommand);
        }

        /**
         * Process some command.
         */
        private function handleCommand(event:CommandEvent):void
        {
            switch (event.command)
            {
            case "travel":
                startTowardDestination(event.payload);
                break;
            }
        }
    }
}
