using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Net;
using System.Net.Mail;

namespace DaNiet
{
	public class Mailer
	{
		string _server;
		string _username;
		string _password;
		private SmtpClient smtp_client;
	
		public Mailer(string server, string username, string password)
		{
			_server = server;
			_username = username;
			_password = password;
			smtp_client = new SmtpClient
				{
					Host = _server,
					//Port = 587,
					//EnableSsl = false,
					DeliveryMethod = SmtpDeliveryMethod.Network,
					UseDefaultCredentials = false,
					Credentials = new NetworkCredential(_username, _password)
				};
		}
		
		public void Send(EMail msg)
		{
			using (var message = new MailMessage(msg.From == "" ? new MailAddress(_username, "Robot") : new MailAddress(msg.From), new MailAddress(msg.To))
				{
					Subject = msg.Subject,
					Body = msg.Body,
					IsBodyHtml = true
				})
			{
				var html_view = AlternateView.CreateAlternateViewFromString(msg.Html, null, "text/html");
				message.AlternateViews.Add(html_view);
			    smtp_client.Send(message);
			}
		}
	}
	
	public class EMail
	{
		static Mailer default_mailer = new Mailer("eumail.avaya.com", "rvrobot@avaya.com", "RvShos42");
		
		public string From { get; set; }
		public string To { get; set; }
		public string Cc { get; set; }
		public string Bcc { get; set; }
		public string Subject { get; set; }
		public string Body { get; set; }
		public string Html { get; set; }
	
		protected void ctor(string from, string[] to, string[] cc, string[] bcc, string subject, string body, string html = "")
		{
			From = from;
			To = to[0];
			//Cc = cc[0];
			//Bcc = bcc[0];
			Subject = subject;
			Body = body;
			Html = html != "" ? html : body;
		}
		
		public EMail(string to, string subject, string body, string html = "")
		{
			var empty = new string[] {};
			ctor("", new string[] { to }, empty, empty, subject, body, html);
		}
	
		public EMail(string from, string to, string subject, string body, string html = "")
		{
			var empty = new string[] {};
			ctor(from, new string[] { to }, empty, empty, subject, body, html);
		}
		
		public EMail(string from, string[] to, string[] cc, string[] bcc, string subject, string body, string html = "")
		{
			ctor("", to, cc, bcc, subject, body, html);
		}
	
		public void Send(Mailer mailer)
		{
			mailer.Send(this);
		}
	
		public void Send()
		{
			Send(default_mailer);
		}
		
		public Mailer DefaultMailer { set { default_mailer = value; } }
	}
}
