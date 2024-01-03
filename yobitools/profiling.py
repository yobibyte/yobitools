import cProfile
import time

def profileit(name):
    """Profiling decorator

    Add @profileit('your_name') for a function to run cprof on it
    Based on https://stackoverflow.com/a/5376616

    Parameters
    ----------
    name: str
        name of the file to save profiling results to

    Returns
    -------

    """

    def inner(func):
        def wrapper(*args, **kwargs):
            prof = cProfile.Profile()
            retval = prof.runcall(func, *args, **kwargs)
            # Note use of name from outer scope
            prof.dump_stats(name)
            return retval

        return wrapper

    return inner


def timeit(name):
    """Timing decorator

    Add @timeit('name') to time execution of the function.
    Built in the same way as profileit above.

    Parameters
    ----------
    name: str
        Name to see in the output.

    Returns
    -------

    """

    def inner(func):
        def wrapper(*args, **kwargs):
            ts = time.time()
            result = func(*args, **kwargs)
            te = time.time()
            print('%s, took: %2.4f sec' % (name, te - ts))
            return result

        return wrapper

    return inner
