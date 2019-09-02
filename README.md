<p><b>Notes:</b></p>
<ul>
    <li>We're using PostgreSQL.</li>
    <li>We're using PostGIS. Be sure to enable PostGIS in the PostgreSQL database.</li>
    <li>A third-party PostGIS support library is being used. Be wary of this.</li>
</ul>
<p><b>Goals:</b></p>
<ul>
    <li>Users own a UserInformation that contains their information. To start, this will just be their geograpic location.</li>
    <li>The first version of "The Algorithm" will query users based on geographic proximity. This is where PostGIS is vital.</li>
    <li>It's possible that location eventually becomes irrelevant. Do not overuse PostGIS.</li>
</ul>

# Basin

## Installing:

1. Install Vapor (3 -- I plan to upgrade to 4 when it is released).
2. Install PostgreSQL and PostGIS. On Mac OS X, I just used Postgres.app.
3. 
