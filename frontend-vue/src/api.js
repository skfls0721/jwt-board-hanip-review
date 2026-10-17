let session = { accessToken: "", user: null };

export const getSession = () => session;

export function clearSession() {
  session = { accessToken: "", user: null };
}

function authorizationHeaders() {
  if (!session.accessToken) {
    return {};
  }

  return {
    Authorization: `Bearer ${session.accessToken}`,
  };
}

function getErrorMessage(status, code, message) {
  if (status === 400) {
    return `입력 오류: ${message || "입력 내용을 확인해 주세요."}`;
  }

  if (status === 401) {
    if (code === "INVALID_CREDENTIALS") {
      return "이메일 또는 비밀번호가 올바르지 않습니다.";
    }
    if (code === "TOKEN_REQUIRED") {
      return "로그인이 필요합니다. 다시 로그인해 주세요.";
    }
    if (code === "TOKEN_EXPIRED") {
      return "로그인 시간이 만료되었습니다. 다시 로그인해 주세요.";
    }
    if (code === "INVALID_TOKEN") {
      return "인증 정보가 유효하지 않습니다. 다시 로그인해 주세요.";
    }
    return "인증에 실패했습니다. 다시 로그인해 주세요.";
  }

  if (status === 403) {
    return "권한이 없습니다. 본인이 작성한 게시글만 수정하거나 삭제할 수 있습니다.";
  }

  if (status === 404) {
    return "게시글을 찾을 수 없습니다. 목록을 새로고침해 주세요.";
  }

  return message || code || `요청 처리에 실패했습니다. (HTTP ${status})`;
}

export async function request(path, options = {}) {
  let response;
  try {
    response = await fetch(`/api${path}`, {
      ...options,
      headers: {
        "Content-Type": "application/json",
        ...authorizationHeaders(),
        ...options.headers,
      },
    });
  } catch {
    const error = new Error(
        "서버에 연결할 수 없습니다. 백엔드가 실행 중인지 확인해 주세요.",
    );
    error.status = 0;
    throw error;
  }

  let data = null;
  if (response.status !== 204) {
    try {
      data = await response.json();
    } catch {
      data = null;
    }
  }

  if (!response.ok) {
    if (response.status === 401) {
      clearSession();
    }

    const error = new Error(
      getErrorMessage(response.status, data?.code, data?.message),
    );
    error.status = response.status;
    error.code = data?.code;
    throw error;
  }

  return data;
}

export async function login(email, password) {
  const result = await request("/auth/login", {
    method: "POST",
    body: JSON.stringify({ email, password }),
  });

  session = {
    accessToken: result.accessToken,
    user: result.user,
  };

  return session.user;
}

export function canEdit(post) {
  return Boolean(
    session.user &&
    post &&
    Number(session.user.id) === Number(post.authorId)
  );
}

export const api = {
  list: () => request("/posts"),
  detail: (id) => request(`/posts/${id}`),
  create: (input) =>
    request("/posts", {
      method: "POST",
      body: JSON.stringify(input),
    }),
  update: (id, input) =>
    request(`/posts/${id}`, {
      method: "PUT",
      body: JSON.stringify(input),
    }),
  remove: (id) =>
    request(`/posts/${id}`, { method: "DELETE" }),
  me: () => request("/me"),
};
