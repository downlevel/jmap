package it.downlevel.jmap.servlets;

import it.downlevel.jmap.config.DBConfig;
import it.downlevel.jmap.model.Category;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.io.UnsupportedEncodingException;
import java.net.URL;
import java.net.URLConnection;
import java.net.URLEncoder;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.sql.DataSource;

import com.google.gson.Gson;
import com.google.gson.JsonSyntaxException;


public class CategoryServlet extends HttpServlet{
	
	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {

		//Oggetti per query
		Connection conn = null;
		Statement stmt = null;
		ResultSet res = null;
		Context context;
		
		//Lista CAtegorie
		ArrayList<Category> categoryList = new ArrayList<Category>();
		
		try {
			context = new InitialContext();
			DataSource dataSource = (DataSource) context.lookup(DBConfig.dataSource);
			conn = dataSource.getConnection();
			stmt = conn.createStatement();
			res = stmt.executeQuery(DBConfig.category_query);
			
			while (res.next()) {

				Category category =new Category();
				category.setId(res.getString("category_id"));
				category.setName(res.getString("desc_cat"));
				categoryList.add(category);

			}
			
			//Chiudo connessioni 
			res.close();
			stmt.close();
			conn.close();
			
		} catch (NamingException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		Gson gson = new Gson();
		String JsonString = gson.toJson(categoryList, ArrayList.class);
		PrintWriter out = resp.getWriter(); 
		out.print(JsonString);

	}

}