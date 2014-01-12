package com.kayak.motion
{
    /**
     * Utilities that support motion calculations.
     *
     * Do not instantiate.
     */
    public class MotionUtil
    {
        /**
         * A small number.
         */
        public static const EPSILON:Number = 0.00001;

        /**
         * Return true if the two values are approximately equal.
         */
        public static function approximate(x:Number, y:Number):Boolean
        {
            return Math.abs(x - y) < EPSILON;
        }

        /**
         * Return true if the given value is approximately equal to zero.
         */
        public static function isZero(x:Number):Boolean
        {
            return x > -EPSILON && x < EPSILON
        }
    }
}
