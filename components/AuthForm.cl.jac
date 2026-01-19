"""Authentication form component for login/signup."""

def:pub AuthForm(
    isSignup: bool,
    username: str,
    password: str,
    error: str,
    loading: bool,
    onUsernameChange: any,
    onPasswordChange: any,
    onSubmit: any,
    onToggleMode: any
) -> any {
    return
        <div className="auth-container">
            <h1 className="auth-title">
                Jac Todo App
            </h1>
            <p className="auth-subtitle">
                {("Create an account" if isSignup else "Sign in to your account")}
            </p>
            {(
                <div className="auth-error">
                    {error}
                </div>
            )
            if error
            else None}
            <form onSubmit={onSubmit}>
                <input
                    type="text"
                    value={username}
                    onChange={onUsernameChange}
                    placeholder="Username"
                    className="auth-input"
                />
                <input
                    type="password"
                    value={password}
                    onChange={onPasswordChange}
                    placeholder="Password"
                    className="auth-input auth-input-last"
                />
                <button
                    type="submit"
                    disabled={loading}
                    className="btn-submit"
                >
                    {(
                        (
                            "Processing..."
                            if loading
                            else ("Sign Up" if isSignup else "Log In")
                        )
                    )}
                </button>
            </form>
            <p className="auth-footer">
                {(
                    "Already have an account? "
                    if isSignup
                    else "Don't have an account? "
                )}
                <span
                    onClick={onToggleMode}
                    className="auth-link"
                >
                    {("Log In" if isSignup else "Sign Up")}
                </span>
            </p>
        </div>;
}
