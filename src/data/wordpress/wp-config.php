<?php
/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the installation.
 * You don't have to use the web site, you can copy this file to "wp-config.php"
 * and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * Database settings
 * * Secret keys
 * * Database table prefix
 * * Localized language
 * * ABSPATH
 *
 * @link https://wordpress.org/support/article/editing-wp-config-php/
 *
 * @package WordPress
 */

// ** Database settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define( 'DB_NAME', 'wordpress' );

/** Database username */
define( 'DB_USER', 'mehdi' );

/** Database password */
define( 'DB_PASSWORD', 'polo' );

/** Database hostname */
define( 'DB_HOST', 'mariadb' );

/** Database charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8' );

/** The database collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', '' );

/**#@+
 * Authentication unique keys and salts.
 *
 * Change these to different unique phrases! You can generate these using
 * the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}.
 *
 * You can change these at any point in time to invalidate all existing cookies.
 * This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define( 'AUTH_KEY',          '/sa~bN:}?a(yONJhm}R|nPK)D63]7xF)`cFY@:Z:tp2Jf Q&!KN<mv>Nt{/p.W&%' );
define( 'SECURE_AUTH_KEY',   'o+dV_I/zi{24wlYP%5S6cOeL!}F!l!7)h}Dk3`Ui:@+GCgqkj(op`SW]Is%<+#WI' );
define( 'LOGGED_IN_KEY',     'BlK)3]k.&KK:)~2D~}h{I>A:XH9ml)$u]IP9HxxQU/4Sz]V^E;a~us.89OZ[Wd?q' );
define( 'NONCE_KEY',         'q.sH[tn~OfHANS.WU3$}-=&2pn{w:lNeQBe{;l z-5(0p:FE+l2slB<[ci/*_FDY' );
define( 'AUTH_SALT',         'Sc67T.u[TrM,7mZAHuUwy*/M%<Z_-HoFYbd)R_slp)$?J5b2mJi~)y.x|r<+>JY&' );
define( 'SECURE_AUTH_SALT',  'Zmng/kHE}MZpQs+~A+Zy0dJ6r6 Q-0q[nbr!<how|gaEiw/z=W*51yCw17ngOreN' );
define( 'LOGGED_IN_SALT',    'S}tAR#Gbs?ms4aKD!Nl-8:3;gP(G>r|F>JD4c<4E02Eg@sGQ:VujnTv(`Pj>?UJU' );
define( 'NONCE_SALT',        'Yn15eC {o U;+36igenkhar7|y+kJPNC^=r3?^Z-,&sDD_,[mFBe|e_1;84mJ(p6' );
define( 'WP_CACHE_KEY_SALT', 'NOH)y%CVB&3Fa3 < 3YAJ<X$y:EZ^ml$5ih)6=kyG2x~`lW[;,mmuU95{W~Nq~1(' );


/**#@-*/

/**
 * WordPress database table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
$table_prefix = 'wp_';


/* Add any custom values between this line and the "stop editing" line. */



/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the documentation.
 *
 * @link https://wordpress.org/support/article/debugging-in-wordpress/
 */
if ( ! defined( 'WP_DEBUG' ) ) {
	define( 'WP_DEBUG', false );
}

/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', __DIR__ . '/' );
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';
