import { Component, type ErrorInfo, type ReactNode } from 'react'

interface ErrorBoundaryProps {
  children: ReactNode
}

interface ErrorBoundaryState {
  hasError: boolean
}

export class ErrorBoundary extends Component<ErrorBoundaryProps, ErrorBoundaryState> {
  state: ErrorBoundaryState = { hasError: false }

  static getDerivedStateFromError(): ErrorBoundaryState {
    return { hasError: true }
  }

  componentDidCatch(error: Error, info: ErrorInfo) {
    console.error(error, info)
  }

  render() {
    if (this.state.hasError) {
      return (
        <section className="screen">
          <h1>うまくいかなかったよ</h1>
          <button
            type="button"
            className="btn primary"
            onClick={() => this.setState({ hasError: false })}
          >
            もういちど
          </button>
        </section>
      )
    }
    return this.props.children
  }
}
