![](./public/assets/kirigami-app-icon-192.png)

# Kirigami Labs - Vyper Examples

Welcome to Vyper examples from Kirigami Labs!

Homepage: [https://kirigamilabs.com](https://kirigamilabs.com)

We are building on the shoulders of giants and are proud to say that we leverage tools provided by those that came before us. 

Special thanks to the Ethereum and Vyper Lang organizations for providing amazing products and thank you specifically to Charles Cooper, pcaversaccio, and all others who have contributed to the development and growth of the Vyper language. 

## Kirigami Labs - Vyper Example

- [Node.js](https://nodejs.org/)
- [Yarn package manager](https://yarnpkg.com/cli/install)
- [React](https://reactjs.org/) - A JavaScript library for building component-based user interfaces
- [Typescript](https://www.typescriptlang.org/) - TypeScript is a strongly typed programming language that builds on JavaScript
- [Chakra UI](https://chakra-ui.com/) - A UI library
- [GitHub Actions](https://github.com/features/actions) - Manages CI/CD, and issue tracking

## Local environment setup

Ensure you're using the correct version of Node.js:

```bash
nvm use
```

Or see [.nvmrc](.nvmrc) for correct version.

Install dependencies:

```bash
yarn
```

Run the development server:

```bash
yarn dev
```

Open [http://localhost:3000](http://localhost:3000) in your browser to view the site.

## Code structure

| Folder                   | Primary use                                                                                     |
| ------------------------ | ----------------------------------------------------------------------------------------------- |
| `/src`                   | Main source folder for development                                                              |
| `/src/components`        | React components that do not function as standalone pages                                       |
| `/src/events`            | Markdown files for **events**                                                                   |
| `/src/hooks`             | Custom React hooks                                                                              |
| `/src/pages`             | React components that function as standalone pages and will create URL paths                    |
| `/src/posts`             | Markdown files for **blog posts**                                                               |
| `/src/styles`            | Custom style declarations                                                                       |
| `/src/theme`             | Declares site color themes, breakpoints and other constants (try to utilize these colors first) |
| `/src/theme/foundations` | Theme foundations imported by theme config at `/src/theme`                                      |
| `/src/utils`             | Custom utility scripts                                                                          |
| `/src/constants.ts`      | Declares all constants that are used throughout the site.                                       |
| `/src/interfaces.ts`     | Declared interfaces and types for to be used throughout the site                                |
| `/public`                | Storage for assets that will be available at URL path after build                               |
| `/public/assets`         | General image assets                                                                            |
| `/public/img`            | Image assets used in blog posts                                                                 |



## Learn more about the stack

- [Next.js Documentation](https://nextjs.org/docs) - learn about Next.js features and API.
- [Learn Next.js](https://nextjs.org/learn) - an interactive Next.js tutorial.
- [Chakra UI Documentation](https://chakra-ui.com/docs/getting-started) - learn about Chakra UI features and API.


## Inspiration

“No one is useless in this world,' retorted the Secretary, 'who lightens the burden of it for any one else.”

― Charles Dickens, Our Mutual Friend