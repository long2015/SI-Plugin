// Returns offset of target string in source string

// Return X if target string is not found

macro FindString( source, target )
{
	source_len = strlen( source )
	target_len = strlen( target )


	match = 0
	cp = 0


	while( cp < source_len )
	{
		while( cp < source_len )
		{
			if( source[cp] == target[0] )
				break
			else
				cp = cp + 1
		}

		if( cp == source_len )
		    break;
		
		k = cp
		j = 0
		while( j < target_len && source[k] == target[j] )
		{
			k = k + 1
			j = j + 1
		}
		
		if (j == target_len)
		{
			match = 1
			break
		}
		
		cp = cp + 1
	}

	if( match )
		return cp
	else
		return "X"
}

// Same as FindString but starts from end of source string
macro RFindString( source, target )
{
	source_len = strlen( source )
	target_len = strlen( target )

	match = 0
	cp = source_len - 1

	while( cp >= (target_len - 1) )
	{
		while( cp >= (target_len - 1) )
		{
			if( source[cp] == target[target_len-1] )
				break
			else
				cp = cp - 1
		}

		if( cp < (target_len - 1) )
		    break;

		k = cp
		j = target_len - 1
		while( source[k] == target[j] )
		{
			k = k - 1
			j = j - 1

			// SI does not short curcuit &&
			if( j < 0 )
				break;
		}
		
		if( j < 0 )
		{
			match = 1
			break;
		}
		
		cp = cp - 1
	}

	if( match )
		return cp - (target_len - 1)
	else
		return "X"
}


// Returns the index of the first non whitespace character
// Search starts at offset specified by 'first'
macro SkipWS( string, first )
{
    len = strlen( string )
    i = first
    
    while( i < len )
    {
        if( string[i] == " " || string[i] == "	" )
    		i = i + 1
		else
		    break
    }

	if( i == len )
		return "X"
	else
	    return i
}


// Finds the next whitespace character in the passed in string.
// Search starts at offset specified by 'first'
macro NextWS( string, first )
{
    len = strlen( string )
    i = first

    while( i < len )
    {
        if( string[i] != " " && string[i] != "	" )
    		i = i + 1
		else
		    break
    }

  	if( i == len )
		return "X"
 	else
	    return i
	    }