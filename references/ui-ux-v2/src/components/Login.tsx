import React, { useState } from "react";
import { Button } from "./ui/button";
import { Input } from "./ui/input";
import { Label } from "./ui/label";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "./ui/card";
import { Checkbox } from "./ui/checkbox";
import {
  Building2,
  Lock,
  Mail,
  AlertCircle,
} from "lucide-react";
import { Alert, AlertDescription } from "./ui/alert";

interface LoginProps {
  onLogin: () => void;
}

export function Login({ onLogin }: LoginProps) {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [rememberMe, setRememberMe] = useState(false);
  const [error, setError] = useState("");
  const [isLoading, setIsLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");
    setIsLoading(true);

    // Simulate authentication delay
    setTimeout(() => {
      // Simple validation (replace with actual authentication)
      if (
        email === "admin@villagetech.com" &&
        password === "admin"
      ) {
        onLogin();
      } else {
        setError(
          "Invalid email or password. Try admin@villagetech.com / admin",
        );
        setIsLoading(false);
      }
    }, 1000);
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-[#f0f4f2] to-[#e8eeeb] relative overflow-hidden">
      {/* Background decoration */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <div className="absolute top-0 left-0 w-96 h-96 bg-[#105640]/10 rounded-full blur-3xl -translate-x-1/2 -translate-y-1/2"></div>
        <div className="absolute bottom-0 right-0 w-96 h-96 bg-[#2D7D5C]/10 rounded-full blur-3xl translate-x-1/2 translate-y-1/2"></div>
        <div className="absolute top-1/2 left-1/2 w-72 h-72 bg-[#F59E0B]/10 rounded-full blur-3xl -translate-x-1/2 -translate-y-1/2"></div>
      </div>

      <div className="w-full max-w-md px-6 relative z-10">
        {/* Logo and branding */}
        <div className="text-center mb-8">
          <div className="inline-flex items-center justify-center w-16 h-16 bg-gradient-to-br from-[#105640] to-[#2D7D5C] rounded-2xl mb-4 shadow-xl">
            <Building2 className="h-9 w-9 text-white" />
          </div>
          <h1 className="text-3xl font-bold text-[#105640] mb-2">
            Village Tech
          </h1>
          <p className="text-[#5a6c63]">
            Platform Administration
          </p>
        </div>

        {/* Login card */}
        <Card className="shadow-xl border-[#d1dcd6] bg-white/80 backdrop-blur-sm">
          <CardHeader className="space-y-1 pb-6">
            <CardTitle className="text-2xl text-center text-[#105640]">
              Welcome Back
            </CardTitle>
            <CardDescription className="text-center text-[#5a6c63]">
              Sign in to access the platform admin dashboard
            </CardDescription>
          </CardHeader>
          <CardContent>
            <form onSubmit={handleSubmit} className="space-y-5">
              {error && (
                <Alert variant="destructive" className="py-3">
                  <AlertCircle className="h-4 w-4" />
                  <AlertDescription>{error}</AlertDescription>
                </Alert>
              )}

              <div className="space-y-2">
                <Label htmlFor="email">Email Address</Label>
                <div className="relative">
                  <Mail className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-[#5a6c63]" />
                  <Input
                    id="email"
                    type="email"
                    placeholder="admin@villagetech.com"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    className="pl-10 bg-white border-[#d1dcd6] focus:border-[#105640] focus:ring-[#105640]"
                    required
                    disabled={isLoading}
                  />
                </div>
              </div>

              <div className="space-y-2">
                <Label htmlFor="password">Password</Label>
                <div className="relative">
                  <Lock className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-[#5a6c63]" />
                  <Input
                    id="password"
                    type="password"
                    placeholder="Enter your password"
                    value={password}
                    onChange={(e) =>
                      setPassword(e.target.value)
                    }
                    className="pl-10 bg-white border-[#d1dcd6] focus:border-[#105640] focus:ring-[#105640]"
                    required
                    disabled={isLoading}
                  />
                </div>
              </div>

              <div className="flex items-center justify-between">
                <div className="flex items-center space-x-2">
                  <Checkbox
                    id="remember"
                    checked={rememberMe}
                    onCheckedChange={(checked) =>
                      setRememberMe(checked as boolean)
                    }
                    disabled={isLoading}
                  />
                  <label
                    htmlFor="remember"
                    className="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70 text-[#0a0f0d] cursor-pointer"
                  >
                    Remember me
                  </label>
                </div>
                <Button
                  type="button"
                  variant="link"
                  className="px-0 text-[#2D7D5C] hover:text-[#105640]"
                  disabled={isLoading}
                >
                  Forgot password?
                </Button>
              </div>

              <Button
                type="submit"
                className="w-full bg-gradient-to-r from-[#105640] to-[#2D7D5C] hover:from-[#0d4533] hover:to-[#256b4d] text-white shadow-lg hover:shadow-xl transition-all duration-200"
                disabled={isLoading}
              >
                {isLoading ? "Signing in..." : "Sign In"}
              </Button>
            </form>

            <div className="mt-6 pt-6 border-t border-[#d1dcd6]">
              <p className="text-center text-sm text-[#5a6c63]">
                Demo credentials:{" "}
                <span className="font-medium text-[#105640]">
                  admin@villagetech.com
                </span>{" "}
                /{" "}
                <span className="font-medium text-[#105640]">
                  admin
                </span>
              </p>
            </div>
          </CardContent>
        </Card>

        {/* Footer */}
        <p className="text-center text-sm text-[#5a6c63] mt-8">
          © 2025 Village Tech. All rights reserved.
        </p>
      </div>
    </div>
  );
}