package com.kayak.globe
{
    import flash.display.DisplayObject;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.utils.getTimer;

    /**
     * Type of event dispatched when this controller starts moving
     * the globe.
     */
    [Event("startMotion")]

    /**
     * Type of event dispatched when this controller stops moving
     * the globe.
     */
    [Event("stopMotion")]

    /**
     * Base class for a globe controller.
     *
     * Base implementation handles animation frame rate.
     */
    public class GlobeController extends EventDispatcher
    {
        /**
         * Control frame interval, in milliseconds.
         */
        public static const PULSE_INTERVAL:int = 50;

        /**
         * Type of event dispatched when this controller starts moving
         * the globe.
         */
        public static const START_MOTION:String = "startMotion";

        /**
         * Type of event dispatched when this controller stops moving
         * the globe.
         */
        public static const STOP_MOTION:String = "stopMotion";

        // The globe view under control of this controller.
        private var _globe:GlobeView;

        // For interval timing.
        private var _lastPulseTime:int;

        private var _parent:DisplayObject;

        /**
         * Constructor.
         */
        public function GlobeController(globe:GlobeView, parent:DisplayObject)
        {
            _globe = globe;
            _lastPulseTime = getTimer();
            _parent = parent;

            // Add event listener to drive rendering.
            parent.addEventListener(Event.ENTER_FRAME, handleEnterFrame);
        }
        
        /**
         * What to do on ENTER_FRAME.
         */
        private function handleEnterFrame(event:Event):void
        {
            var timer:int = getTimer();
            var elapsed:Number = timer - _lastPulseTime;
            if (elapsed >= PULSE_INTERVAL)
            {
                update(elapsed);
                _globe.redraw();
                _lastPulseTime = timer;
            }
        }

        /**
         * Get the globe under control of this controller.
         */
        public function get globe():GlobeView
        {
            return _globe;
        }

        /**
         * Update the state of the globe to show the passage of time.
         *
         * Must be extended by subclass - default implementation does nothing.
         *
         * @param elapsed the number of milliseconds that have elapsed since
         *                the last call to this method
         */
        protected function update(elapsed:Number):void
        {
        }

        /**
         * Stop any process managed by this controller and unregister
         * listeners, allowing this controller to be garbage collected.
         *
         * May be extended by subclass - extended implementation must call
         * superclass implementation.
         */
        public function destroy():void
        {
            _parent.removeEventListener(Event.ENTER_FRAME, handleEnterFrame);
        }
    }
}
