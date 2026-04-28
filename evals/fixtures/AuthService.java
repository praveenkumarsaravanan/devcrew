package com.example.auth;

import java.sql.*;
import javax.servlet.http.*;

public class AuthService {

    private Connection db;

    // BUG 1 (CRITICAL - SQL Injection): User input concatenated into query
    public User login(String username, String password) throws SQLException {
        String query = "SELECT * FROM users WHERE username = '" + username
                     + "' AND password = '" + password + "'";
        Statement stmt = db.createStatement();
        ResultSet rs = stmt.executeQuery(query);
        if (rs.next()) {
            return new User(rs.getString("username"), rs.getString("role"));
        }
        return null;
    }

    // BUG 2 (CRITICAL - Plaintext password comparison): No hashing
    public boolean verifyPassword(String input, String stored) {
        return input.equals(stored);
    }

    // BUG 3 (HIGH - Missing rate limiting): No brute force protection
    public String authenticate(HttpServletRequest request) throws SQLException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        User user = login(username, password);
        if (user != null) {
            String token = generateToken(user);
            return token;
        }
        return null;
    }

    // BUG 4 (HIGH - Weak token): Predictable token generation
    private String generateToken(User user) {
        return user.getUsername() + "-" + System.currentTimeMillis();
    }

    // BUG 5 (MEDIUM - Information disclosure): Detailed error messages
    public User getUser(String id) throws SQLException {
        try {
            String query = "SELECT * FROM users WHERE id = ?";
            PreparedStatement stmt = db.prepareStatement(query);
            stmt.setString(1, id);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return new User(rs.getString("username"), rs.getString("role"));
            }
            throw new RuntimeException("User not found in database table 'users' for id: " + id);
        } catch (SQLException e) {
            throw new RuntimeException("Database error: " + e.getMessage() + " Query failed for table: users", e);
        }
    }

    // BUG 6 (MEDIUM - No input validation): Missing null/empty checks
    public void resetPassword(String userId, String newPassword) throws SQLException {
        String query = "UPDATE users SET password = ? WHERE id = ?";
        PreparedStatement stmt = db.prepareStatement(query);
        stmt.setString(1, newPassword);
        stmt.setString(2, userId);
        stmt.executeUpdate();
    }
}
