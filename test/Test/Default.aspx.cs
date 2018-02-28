using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class _Default : System.Web.UI.Page
{
	DataTable dt = new DataTable();
	protected void Page_Load(object sender, EventArgs e)
	{
		if (Request.QueryString != null)
		{
			if (!IsPostBack)
			{


			}
			if (Request.QueryString["ID"] != "")
			{
				int ReqID = 0;
				ReqID = Convert.ToInt32(Request.QueryString["ID"].ToString());
				string strQuery = "";
				string id = Convert.ToString(ReqID);
				if (id != "0")
				{
					strQuery = "select * from [Table] WHERE ID =" + id + "";
					SqlCommand cmd = new SqlCommand(strQuery);
					dt = GetData(cmd);
					GridView1.DataSource = dt;
					GridView1.DataBind();
				}
			}
		}
			
	}
	private DataTable GetData(SqlCommand cmd)
	{
		DataTable dt = new DataTable();
		String strConnString = System.Configuration.ConfigurationManager.ConnectionStrings["SQL"].ConnectionString;
		SqlConnection con = new SqlConnection(strConnString);
		SqlDataAdapter sda = new SqlDataAdapter();
		cmd.CommandType = CommandType.Text;
		cmd.Connection = con;
		try
		{
			con.Open();
			sda.SelectCommand = cmd;
			sda.Fill(dt);

		}
		catch (Exception ex)
		{
			throw ex;
			//return null;
		}
		finally
		{
			con.Close();
			sda.Dispose();
			con.Dispose();
		}
		return dt;
	}
}