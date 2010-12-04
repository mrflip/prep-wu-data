import java.util.*;

/*
 *
 *  Defines a class for calculating the percentiles of every element in an array.
 *  Right now it only eats arrays with values in (0,10). I know. Too bad.
 *
 */

public class Percentiles {

    private double[] arr_with_percentiles;
    private int len;

    //
    //  Return an array of interpolated percentiles (from 0 to 100)
    //
    public double[][] percentiles(final double[] arr) {
        // RUBY: arr.map{|x| percentile(x)}
        len = arr.length;
        arr_with_percentiles = new double[len];
        for (int i = 0; i < len; i++) {
            arr_with_percentiles[i] = percentile(arr, arr[i]);
        }
        return interpolated_percentiles(arr);
    }

    //
    // Return percentile with interpolation
    //
    private double percentile(final double[] arr, double x) {
        // RUBY: ((arr.num_less_than(x) + 0.5*arr.frequency_of(x))/arr.size.to_f)*100.0
        double dbl_sz = (double)len;
        return ((num_less_than(arr, x) + 0.5*frequency_of(arr, x))/dbl_sz)*100.0;
    }

    //
    // Count number of elements in arr less than x
    //
    private double num_less_than(final double[] arr, double x) {
        //RUBY: arr.inject(0){|count,y| count += 1 if y < x; count}
        double sum = 0.0;
        for (int i = 0; i < len; i++) {
            if (arr[i] < x) {
                sum += 1.0;
            }
        }
        return sum;
    }

    //
    // Count number of occurrences of x
    //
    private double frequency_of(final double[] arr, double x) {
        //RUBY: arr.inject(0){|count,y| count += 1 if x == y; count}
        double count = 0.0;
        for (int i = 0; i < len; i++) {
            if (arr[i] == x) {
                count += 1.0;
            }
        }
        return count;
    }

    //
    // Given an x between pair1 and pair2 return it's y value.
    //
    private double interpolate(double [] pair1, double [] pair2, double x) {
        double m = (pair2[1] - pair1[1])/(pair2[0] - pair1[0]); // slope
        double b = pair2[1] - m*pair2[0];                       // y-intercept
        return m*x + b;
    }

    //
    // This is disgusting.
    //
    private double[][] interpolated_percentiles(double[] arr) {
        double dx = 0.1;

        //How many pairs are we going to return?
        double max_x = 10.0;
        double min_x = 0.0;
        int num_pts = (int)Math.round(Math.abs(max_x - min_x)/dx);
        //

        // Create an array to return, this will contain pairs (raw_val => percentile)
        double prs[][] = new double[num_pts][2];
        int idx = 0; // will keep track of how many pairs we've added

        //Uninterpolated
        int raw_length = arr.length + 2; //we're going to stuff a value on the beginning and end
        double raw[][] = new double[raw_length][2];
        for (int i = 1; i < arr.length; i++) {
            double a[] = {arr[i],arr_with_percentiles[i]};
            raw[i] = a;
        }

        // Peg values on the beginning and end so we always have a complete table
        double dummy_max[] = {10.0, 100.0};
        double dummy_min[] = {0.0, 0.0};
        raw[arr.length]    = dummy_max;
        raw[0]             = dummy_min;

        //Do the actual interpolation
        for (int i = 0; i < raw_length - 2; i++) {
        
            double pair1[] = raw[i];
            double pair2[] = raw[i+1];
            double x1 = pair1[0];  
            double x2 = pair2[0];
            int n_steps = (int)Math.round(Math.abs(x2 - x1)/dx);
            for (int j = 0; j < n_steps; j++) {
                //interpolate
                double x_val = x1 + (double)j*dx;
                double interpolated_pair[] = {x_val, interpolate(pair1,pair2,x_val)};
                prs[idx] = interpolated_pair;
                idx += 1;
            }
        }
        return prs;
    }
}
