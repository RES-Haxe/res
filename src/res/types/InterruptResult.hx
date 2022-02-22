package res.types;

enum InterruptResult {
	/** Do nothing */
	NONE;

	/** Drop line but continue rendering */
	DROP;

	/** Stop the rendering **/
	HALT;
}
