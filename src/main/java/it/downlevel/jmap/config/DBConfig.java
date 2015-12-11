package it.downlevel.jmap.config;

public interface DBConfig {

	public static String dataSource = "java:/jdbc/myDatasource";
	public static String category_query = "SELECT category_id, desc_cat FROM category order by desc_cat";
	public static String marker_query = "SELECT * FROM locations order by title";
}
